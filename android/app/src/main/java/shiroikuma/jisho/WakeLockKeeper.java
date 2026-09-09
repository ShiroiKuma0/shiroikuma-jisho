package shiroikuma.jisho;

import android.os.PowerManager;
import android.util.Log;

/**
 * Keeps a partial wakelock genuinely held for the whole life of a long
 * automation job.
 *
 * Acquiring once is not enough on this device. EMUI force-releases an
 * app's partial wakelock a couple of minutes in — visible in
 * {@code dumpsys power} as a "Force Released WakeLocks" line naming our
 * tag — after which the rest of a multi-gigabyte export runs with no
 * wakelock at all. Off the charger the process then lands in
 * uninterruptible kernel sleep (state {@code D}) with its CPU counters
 * completely static, and only resumes when the cable goes back in.
 *
 * Measured on the Mate XT, 2026-09-09: acquired at 00:28:20,
 * force-released at 00:31:03, never re-taken, and the export sat frozen
 * from then on. Both automation services had the same shape — a single
 * {@code if (!wakeLock.isHeld()) acquire(...)} in {@code onStartCommand}
 * and nothing that ever looked again.
 *
 * <p>This runs on its own thread deliberately. During those stalls the
 * main looper thread is itself blocked in {@code D} state, so a
 * {@link android.os.Handler} posted there would be stuck alongside the
 * work it was supposed to protect and could never re-acquire anything.
 */
final class WakeLockKeeper {
    private static final String TAG = "WakeLockKeeper";

    /**
     * How often the lock is re-armed. The observed force-release came
     * at 2m43s, so this is far tighter than needed — but it is a couple
     * of syscalls, and the cost of being late is a stalled export.
     */
    private static final long REACQUIRE_INTERVAL_MS = 15_000L;

    /**
     * Timeout on each acquisition. Re-arming an already-held,
     * non-reference-counted lock simply refreshes this, which also
     * means a job outliving the original 90 minutes no longer loses its
     * wakelock to the timeout.
     */
    private static final long WAKELOCK_TIMEOUT_MS = 90 * 60 * 1000L;

    private final PowerManager.WakeLock wakeLock;
    private volatile boolean running;
    private Thread thread;
    private volatile int reacquisitions;

    WakeLockKeeper(PowerManager.WakeLock wakeLock) {
        this.wakeLock = wakeLock;
    }

    /** Acquire now, and keep re-acquiring until {@link #stop()}. */
    void start() {
        if (running) {
            return;
        }
        running = true;
        thread = new Thread(this::loop, "jisho-wakelock-keeper");
        thread.setDaemon(true);
        thread.start();
    }

    private void loop() {
        while (running) {
            try {
                if (!wakeLock.isHeld()) {
                    // Either the first acquisition, or the platform took
                    // it away from us. Counted so the end-of-job line
                    // says how often that happened.
                    reacquisitions++;
                    Log.w(TAG, "wakelock not held — acquiring (#"
                        + reacquisitions + ")");
                }
                wakeLock.acquire(WAKELOCK_TIMEOUT_MS);
            } catch (Exception e) {
                // Never give up the loop over one failed acquisition:
                // the next pass is 15 seconds away and the job it is
                // protecting may run for an hour.
                Log.e(TAG, "wakelock acquire failed: " + e);
            }
            try {
                Thread.sleep(REACQUIRE_INTERVAL_MS);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return;
            }
        }
    }

    /** Stop re-acquiring and release the lock. Safe to call twice. */
    void stop() {
        running = false;
        if (thread != null) {
            thread.interrupt();
            thread = null;
        }
        // One acquisition is the normal case; more than one means the
        // platform has been taking it off us mid-job, which is worth
        // seeing in the log.
        Log.w(TAG, "job ended; wakelock acquired " + reacquisitions
            + " time(s)");
        try {
            if (wakeLock.isHeld()) {
                wakeLock.release();
            }
        } catch (Exception ignored) {
            // Already released, possibly by the platform.
        }
    }
}
