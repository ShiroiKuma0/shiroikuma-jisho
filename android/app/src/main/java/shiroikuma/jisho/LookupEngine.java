package shiroikuma.jisho;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;

/**
 * The headless Flutter engine behind {@link LookupProvider}: one engine
 * running {@code jishoLookupMain}, started on the first request and kept
 * for {@link #IDLE_MS} after the last one, because 自由作業盤 sends its
 * batches back to back and bringing the AppModel up costs seconds.
 *
 * <p>Everything touching the engine runs on the main looper — Flutter
 * insists — while the provider's binder thread waits on a latch. That is
 * safe because the binder thread is never the main thread.
 *
 * <p>Requests are serialised: the Dart side looks items up one by one
 * anyway, and two interleaved batches would only slow each other.
 */
final class LookupEngine {
    private static final String TAG = "LookupEngine";

    /** How long an idle engine is kept before it is destroyed. */
    static final long IDLE_MS = 60_000;

    /** Longest wait for the engine to come up (AppModel included). */
    static final long STARTUP_TIMEOUT_MS = 30_000;

    private static final Handler MAIN = new Handler(Looper.getMainLooper());
    private static final Object LOCK = new Object();

    private static FlutterEngine engine;
    private static MethodChannel channel;
    private static CountDownLatch ready;

    private static final Runnable TEARDOWN = () -> {
        if (engine != null) {
            Log.e(TAG, "lookup engine idle, destroying");
            engine.destroy();
            engine = null;
            channel = null;
            ready = null;
        }
    };

    private LookupEngine() {}

    /**
     * Ask the Dart side {@code method} with {@code argument} and wait at
     * most {@code timeoutMs} for its {@code OK:…} / {@code ERROR:…} line.
     * Never throws; a failure comes back as an {@code ERROR:} line.
     */
    static String call(Context context, String method, String argument,
                       long timeoutMs) {
        synchronized (LOCK) {
            try {
                CountDownLatch started = ensureStarted(context.getApplicationContext());
                if (!started.await(STARTUP_TIMEOUT_MS, TimeUnit.MILLISECONDS)) {
                    MAIN.post(TEARDOWN);
                    return "ERROR:timeout starting lookup engine";
                }
                AtomicReference<String> answer = new AtomicReference<>();
                CountDownLatch done = new CountDownLatch(1);
                MAIN.post(() -> {
                    MAIN.removeCallbacks(TEARDOWN);
                    if (channel == null) {
                        answer.set("ERROR:lookup engine gone");
                        done.countDown();
                        return;
                    }
                    channel.invokeMethod(method, argument, new MethodChannel.Result() {
                        @Override
                        public void success(Object result) {
                            answer.set(result == null ? "ERROR:no answer" : result.toString());
                            done.countDown();
                        }

                        @Override
                        public void error(String code, String message, Object details) {
                            answer.set("ERROR:" + code + ": " + message);
                            done.countDown();
                        }

                        @Override
                        public void notImplemented() {
                            answer.set("ERROR:not implemented: " + method);
                            done.countDown();
                        }
                    });
                });
                boolean finished = done.await(timeoutMs, TimeUnit.MILLISECONDS);
                MAIN.postDelayed(TEARDOWN, IDLE_MS);
                if (!finished) {
                    // The engine may be wedged on this batch; a fresh one
                    // serves the next call rather than queueing behind it.
                    MAIN.removeCallbacks(TEARDOWN);
                    MAIN.post(TEARDOWN);
                    return "ERROR:timeout after " + timeoutMs + " ms";
                }
                return answer.get();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return "ERROR:interrupted";
            }
        }
    }

    /** Start the engine if there is none; the latch opens on Dart's ready. */
    private static CountDownLatch ensureStarted(Context context)
            throws InterruptedException {
        AtomicReference<CountDownLatch> latch = new AtomicReference<>();
        CountDownLatch posted = new CountDownLatch(1);
        MAIN.post(() -> {
            if (engine == null) {
                Log.e(TAG, "starting lookup engine");
                ready = new CountDownLatch(1);
                final CountDownLatch mine = ready;
                engine = new FlutterEngine(context);
                channel = new MethodChannel(
                    engine.getDartExecutor().getBinaryMessenger(),
                    "shiroikuma.jisho/lookup");
                channel.setMethodCallHandler((call, result) -> {
                    if ("ready".equals(call.method)) {
                        mine.countDown();
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                });
                engine.getDartExecutor().executeDartEntrypoint(
                    new DartExecutor.DartEntrypoint(
                        io.flutter.FlutterInjector.instance()
                            .flutterLoader()
                            .findAppBundlePath(),
                        "jishoLookupMain"));
            }
            latch.set(ready);
            posted.countDown();
        });
        posted.await();
        return latch.get();
    }
}
