package shiroikuma.jisho;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.ParcelFileDescriptor;
import android.os.PowerManager;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;

/**
 * Runs one automation data-door job — an export or an import — for
 * {@link AutomationProvider}, off the binder thread and inside a
 * foreground service so a multi-minute transfer survives the app being
 * backgrounded.
 *
 * <h3>The descriptor, and the temp file beside it</h3>
 *
 * The caller supplies a {@link ParcelFileDescriptor} and gets bytes
 * written into it (export) or read out of it (import). The Dart export
 * core ({@code StateExport}) works in terms of files, so this service
 * bridges the two with one temp file in {@code cacheDir}:
 *
 * <ul>
 *   <li><b>export</b> — Dart writes the ZIP into our cache, then we
 *       stream it into the caller's descriptor and delete it.</li>
 *   <li><b>import</b> — we stream the caller's descriptor into our
 *       cache, then Dart reads that ZIP and merges it.</li>
 * </ul>
 *
 * A temp file rather than handing Dart {@code /proc/self/fd/N}
 * directly: the ZIP writer seeks, and a descriptor that arrives as a
 * pipe cannot. The copy costs one pass over the archive and removes an
 * entire class of "works on my file, hangs on their pipe".
 *
 * <p><b>Our copy of the descriptor is closed in a {@code finally}.</b>
 * A leaked descriptor holds the caller's file open, and a caller cannot
 * checksum or encrypt a file that is still open.
 */
public class AutomationDataService extends Service {
    private static final String TAG = "AutomationDataService";
    private static final String CHANNEL_ID =
        "shiroikuma.jisho.channel.automation_data";
    private static final int NOTIFICATION_ID = 1046;
    private static final long PROGRESS_THROTTLE_MS = 500;
    private static final String ACTION_CANCEL =
        "shiroikuma.jisho.automation.CANCEL";

    private FlutterEngine engine;
    private PowerManager.WakeLock wakeLock;
    /** Re-acquires the wakelock when the platform force-releases it. */
    private WakeLockKeeper wakeKeeper;
    private final AtomicBoolean replied = new AtomicBoolean(false);
    /** Written from the channel handler and the completion thread. */
    private volatile long lastProgressAt = 0;

    private String jobId;
    private ParcelFileDescriptor descriptor;
    private File workDir;
    private File payload;
    private boolean importing;
    private String replyAction;
    private String replyPackage;
    private String progressAction;

    /** The descriptor cannot ride in an Intent extra across a start, so
     *  it is handed over in memory — this service is process-local to
     *  the provider that started it. */
    private static ParcelFileDescriptor pendingDescriptor;

    static void start(Context context, String jobId,
                      ParcelFileDescriptor descriptor, boolean importing,
                      android.os.Bundle extras) {
        synchronized (AutomationDataService.class) {
            pendingDescriptor = descriptor;
        }
        Intent intent = new Intent(context, AutomationDataService.class);
        intent.putExtra("job_id", jobId);
        intent.putExtra("importing", importing);
        intent.putExtra("items", extras.getString(AutomationProvider.KEY_ITEMS));
        intent.putExtra("reply_action",
            extras.getString(AutomationProvider.KEY_REPLY_ACTION));
        intent.putExtra("reply_package",
            extras.getString(AutomationProvider.KEY_REPLY_PACKAGE));
        intent.putExtra("progress_action",
            extras.getString(AutomationProvider.KEY_PROGRESS_ACTION));
        context.startForegroundService(intent);
    }

    /** Nudges a running job so it notices its cancelled flag promptly. */
    static void requestCancel(Context context, String jobId) {
        Intent intent = new Intent(context, AutomationDataService.class);
        intent.setAction(ACTION_CANCEL);
        intent.putExtra("job_id", jobId);
        try {
            context.startService(intent);
        } catch (Exception ignored) {
            // Nothing running to nudge: the flag is already set and a
            // cancel for a finished job is a silent no-op by contract.
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID, "Automation data",
                NotificationManager.IMPORTANCE_LOW);
            channel.setShowBadge(false);
            getSystemService(NotificationManager.class)
                .createNotificationChannel(channel);
        }
        PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK, "shiroikuma.jisho:automationData");
        wakeLock.setReferenceCounted(false);
        wakeKeeper = new WakeLockKeeper(wakeLock);
    }

    private void notifyProgress(String text) {
        Notification notification =
            new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(getApplicationInfo().icon)
                .setContentTitle("保存復元 — 白い熊 辞書")
                .setContentText(text)
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .build();
        startForeground(NOTIFICATION_ID, notification);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // FIRST, unconditionally, before any branch that might return.
        // Once startForegroundService() has been invoked the platform
        // requires startForeground() whatever this method then decides,
        // and kills the process with
        // ForegroundServiceDidNotStartInTimeException otherwise — so a
        // caller retrying with a stale job id could kill this app on a
        // path that only wanted to stop again. The specific text is set
        // below once we know which job this is.
        notifyProgress("保存復元…");

        if (intent != null && ACTION_CANCEL.equals(intent.getAction())) {
            // The flag is already set by AutomationJobs; this start
            // exists only so a wedged engine is not the reason nothing
            // happens. The running job unwinds at its next boundary.
            //
            // A service is a singleton, so when a job IS running this
            // arrives on that instance and must not tear it down. When
            // nothing is running we have just been created for no
            // reason — a cancel for a finished job is a silent no-op by
            // contract, so leave nothing behind.
            if (jobId == null) {
                stopSelf();
            }
            return START_NOT_STICKY;
        }
        if (intent == null) {
            stopSelf();
            return START_NOT_STICKY;
        }

        synchronized (AutomationDataService.class) {
            descriptor = pendingDescriptor;
            pendingDescriptor = null;
        }

        jobId = intent.getStringExtra("job_id");
        importing = intent.getBooleanExtra("importing", false);
        final String items = intent.getStringExtra("items");
        replyAction = intent.getStringExtra("reply_action");
        replyPackage = intent.getStringExtra("reply_package");
        progressAction = intent.getStringExtra("progress_action");

        notifyProgress(importing ? "取り込み中…" : "書き出し中…");
        // Not a bare acquire(): EMUI force-releases this lock a couple
        // of minutes in, and everything after that ran unprotected —
        // which is what left an export stuck in uninterruptible I/O
        // whenever the phone came off the charger.
        wakeKeeper.start();

        if (descriptor == null) {
            finish("ERROR:no descriptor");
            return START_NOT_STICKY;
        }

        workDir = new File(getCacheDir(), "automation");
        workDir.mkdirs();

        if (importing) {
            // Pull the caller's bytes down first: Dart needs a file.
            payload = new File(workDir, "import_" + jobId + ".zip");
            try (InputStream in = new FileInputStream(descriptor.getFileDescriptor());
                 OutputStream out = new FileOutputStream(payload)) {
                byte[] buffer = new byte[64 * 1024];
                int read;
                long total = 0;
                while ((read = in.read(buffer)) > 0) {
                    if (AutomationJobs.isCancelled(jobId)) {
                        finish("ERROR:cancelled");
                        return START_NOT_STICKY;
                    }
                    out.write(buffer, 0, read);
                    total += read;
                }
                Log.e(TAG, "import payload staged: " + total + " bytes");
            } catch (Exception e) {
                finish("ERROR:" + e.getMessage());
                return START_NOT_STICKY;
            }
        }

        engine = new FlutterEngine(this);
        MethodChannel channel = new MethodChannel(
            engine.getDartExecutor().getBinaryMessenger(),
            "shiroikuma.jisho/automation_data");
        channel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "getRequest": {
                    Map<String, Object> request = new HashMap<>();
                    request.put("mode", importing ? "import" : "export");
                    request.put("items", items);
                    request.put("directory", workDir.getAbsolutePath());
                    request.put("archive",
                        payload == null ? null : payload.getAbsolutePath());
                    result.success(request);
                    break;
                }
                case "isCancelled": {
                    // Polled at write boundaries, never mid-write — so a
                    // cancelled archive is never half a file.
                    result.success(AutomationJobs.isCancelled(jobId));
                    break;
                }
                case "progress": {
                    Number current = call.argument("current");
                    Number total = call.argument("total");
                    Boolean isFinal = call.argument("final");
                    // A file watch owns the progress line for as long as
                    // it runs. Dart keeps its own coarse heartbeat going
                    // underneath (step 2 of 6), and letting both through
                    // makes the count lurch from 3,625,988,096/4,322,062,336
                    // back to 2/6 every few seconds — which 応用管理 reads,
                    // correctly, as the app having restarted its count.
                    if (watchTask != null && !Boolean.TRUE.equals(isFinal)) {
                        result.success(null);
                        break;
                    }
                    emitProgress(
                        call.argument("text"),
                        current == null ? 0L : current.longValue(),
                        total == null ? 0L : total.longValue(),
                        call.argument("unit"),
                        Boolean.TRUE.equals(isFinal));
                    result.success(null);
                    break;
                }
                case "watchFile": {
                    // Dart asks us to report a file's growth because it
                    // cannot report it itself: Isar's copyToFile blocks
                    // the Dart isolate for its whole duration, so timers
                    // there are frozen and a multi-GB copy would look
                    // completely silent. Polling from here is immune to
                    // that.
                    final String watchPath = call.argument("path");
                    final Number watchTotal = call.argument("total");
                    final String watchLabel = call.argument("label");
                    startFileWatch(watchPath,
                        watchTotal == null ? 0L : watchTotal.longValue(),
                        watchLabel == null ? "Copying" : watchLabel);
                    result.success(null);
                    break;
                }
                case "stopWatchFile": {
                    stopFileWatch();
                    result.success(null);
                    break;
                }
                case "done": {
                    String line = call.argument("result");
                    result.success(null);
                    new Handler(Looper.getMainLooper())
                        .post(() -> completionExecutor.execute(
                            () -> complete(line)));
                    break;
                }
                default:
                    result.notImplemented();
            }
        });

        Log.e(TAG, "starting automation data job " + jobId
            + " (" + (importing ? "import" : "export") + ")");
        engine.getDartExecutor().executeDartEntrypoint(
            new DartExecutor.DartEntrypoint(
                io.flutter.FlutterInjector.instance()
                    .flutterLoader()
                    .findAppBundlePath(),
                "automationDataMain"));
        return START_NOT_STICKY;
    }

    private void emitProgress(String text, long current, long total,
                              String unit, boolean isFinal) {
        long now = System.currentTimeMillis();
        if (!isFinal && now - lastProgressAt < PROGRESS_THROTTLE_MS) {
            return;
        }
        lastProgressAt = now;
        if (text != null) {
            notifyProgress(text);
        }
        if (progressAction == null || replyPackage == null) {
            return;
        }
        Intent progress = new Intent(progressAction);
        progress.setPackage(replyPackage);
        progress.addFlags(Intent.FLAG_INCLUDE_STOPPED_PACKAGES);
        // Both keys carry the same value: 応用管理 was handed this id as
        // OK:<job_id> and may correlate on either.
        progress.putExtra("job_id", jobId);
        progress.putExtra("reply_id", jobId);
        progress.putExtra("app", "白い熊 辞書");
        // 応用管理 reads a progress line's label from EXTRA_RESULT, not
        // from "text" — the terminal reply always used "result" but the
        // progress path diverged, so every phase label we emitted was
        // silently discarded on arrival. Both keys are sent: "result"
        // is the one that is read, "text" stays for older receivers.
        progress.putExtra("result", text);
        progress.putExtra("text", text);
        progress.putExtra("current", current);
        progress.putExtra("total", total);
        progress.putExtra("unit", unit);
        sendBroadcast(progress);
    }

    /** How often a watched file's size is sampled. */
    private static final long FILE_WATCH_INTERVAL_MS = 2000;

    /**
     * Where the finished archive is streamed to the caller. Emphatically
     * NOT the main looper: the payload is now measured in gigabytes
     * (1.69 GB on the run of 2026-09-09), and copying that on the looper
     * blocks every platform channel — the app cannot even report
     * progress while it happens, which is precisely what a stalled
     * hand-off looked like.
     */
    private final ExecutorService completionExecutor =
        Executors.newSingleThreadExecutor();

    private final Handler watchHandler = new Handler(Looper.getMainLooper());
    private Runnable watchTask;

    /**
     * Report the growth of {@code path} until {@link #stopFileWatch()}.
     * {@code total} is the expected final size; it may be an
     * over-estimate (a compacted database copy is smaller than the live
     * instance), so the reported figure is clamped rather than allowed
     * to exceed it.
     */
    private void startFileWatch(String path, long total, String label) {
        stopFileWatch();
        if (path == null) {
            return;
        }
        final File watched = new File(path);
        watchTask = new Runnable() {
            @Override
            public void run() {
                long current = watched.exists() ? watched.length() : 0L;
                if (total > 0 && current > total) {
                    current = total;
                }
                emitProgress(label + " " + human(current)
                        + (total > 0 ? "/" + human(total) : ""),
                    current, total, "bytes", false);
                watchHandler.postDelayed(this, FILE_WATCH_INTERVAL_MS);
            }
        };
        watchHandler.post(watchTask);
    }

    private void stopFileWatch() {
        if (watchTask != null) {
            watchHandler.removeCallbacks(watchTask);
            watchTask = null;
        }
    }

    /**
     * Full byte count with thousands separators — 1,685,691,651.
     *
     * Progress lines carry this rather than a rounded size. "1.57 GB"
     * stays on screen unchanged for minutes during a multi-gigabyte
     * step, which is indistinguishable from being stuck; a digit moving
     * anywhere in the number is proof of life.
     */
    private static String human(long bytes) {
        return String.format(java.util.Locale.US, "%,d", bytes);
    }

    /**
     * The Dart side has finished. On an export the ZIP it produced is
     * still ours — stream it into the caller's descriptor before
     * answering, because "OK" must mean the caller has the bytes.
     */
    private void complete(String line) {
        if (AutomationJobs.isCancelled(jobId)) {
            finish("ERROR:cancelled");
            return;
        }
        if (line == null || line.startsWith("ERROR:")) {
            finish(line == null ? "ERROR:no result" : line);
            return;
        }
        if (importing) {
            finish(line);
            return;
        }
        // Export: "OK:<path>|<bytes>|<human>|<n> categories"
        String body = line.substring("OK:".length());
        String producedPath = body.contains("|")
            ? body.substring(0, body.indexOf('|')) : body;
        File produced = new File(producedPath);
        if (!produced.exists()) {
            finish("ERROR:export produced nothing");
            return;
        }
        long copied = 0;
        final long total = produced.length();
        long lastReportAt = 0;
        try (InputStream in = new FileInputStream(produced);
             OutputStream out =
                 new FileOutputStream(descriptor.getFileDescriptor())) {
            byte[] buffer = new byte[64 * 1024];
            int read;
            while ((read = in.read(buffer)) > 0) {
                if (AutomationJobs.isCancelled(jobId)) {
                    // 応用管理 unlinks its staging file when it gives up,
                    // and our descriptor keeps accepting writes that go
                    // nowhere — so stopping here is the only thing that
                    // makes a cancel mean anything.
                    finish("ERROR:cancelled");
                    return;
                }
                out.write(buffer, 0, read);
                copied += read;
                // The receiver's own liveness probe watches our CPU and
                // does not need this; the log does. Without it a
                // multi-gigabyte hand-off is a blank stretch at the very
                // end of a job that already took twenty minutes.
                long now = System.currentTimeMillis();
                if (now - lastReportAt >= PROGRESS_THROTTLE_MS) {
                    lastReportAt = now;
                    emitProgress(
                        "受け渡し " + human(copied) + "/" + human(total),
                        copied, total, "bytes", false);
                }
            }
            out.flush();
            emitProgress("受け渡し完了 " + human(copied),
                copied, total, "bytes", true);
        } catch (Exception e) {
            finish("ERROR:" + e.getMessage());
            return;
        } finally {
            produced.delete();
        }
        finish("OK:" + copied + "|" + humanSize(copied)
            + "|" + body.substring(body.lastIndexOf('|') + 1));
    }

    /**
     * The one terminal reply, the cleanup, and the teardown — all
     * guarded so a cancel racing a success cannot double-fire.
     *
     * A cancelled run must leave nothing behind: the staged payload and
     * any produced archive are deleted here, in the same place that
     * handles every other ending.
     */
    private void finish(String result) {
        if (!replied.compareAndSet(false, true)) {
            return;
        }
        try {
            if (payload != null && payload.exists()) {
                payload.delete();
            }
        } catch (Exception ignored) {
            // Best effort; cache is cache.
        }
        try {
            if (descriptor != null) {
                descriptor.close();
            }
        } catch (Exception ignored) {
            // The caller's own copy is its business.
        }
        descriptor = null;
        AutomationJobs.finish(jobId);
        StateExportReceiver.sendReply(this, replyAction, replyPackage,
            jobId, jobId, result);
        new Handler(Looper.getMainLooper()).post(this::stopSelf);
    }

    private static String humanSize(long bytes) {
        if (bytes >= 1024L * 1024L * 1024L) {
            return String.format("%.2f GB", bytes / (1024.0 * 1024.0 * 1024.0));
        }
        if (bytes >= 1024L * 1024L) {
            return String.format("%.1f MB", bytes / (1024.0 * 1024.0));
        }
        if (bytes >= 1024L) {
            return String.format("%.0f KB", bytes / 1024.0);
        }
        return bytes + " B";
    }

    @Override
    public void onDestroy() {
        // A process death between start and reply leaves the flag set;
        // finish() is idempotent, so this is safe as a backstop.
        if (engine != null) {
            engine.destroy();
            engine = null;
        }
        stopFileWatch();
        completionExecutor.shutdownNow();
        if (wakeKeeper != null) {
            wakeKeeper.stop();
        }
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
