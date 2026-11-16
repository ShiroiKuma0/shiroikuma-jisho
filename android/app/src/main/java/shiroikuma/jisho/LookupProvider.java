package shiroikuma.jisho;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.ParcelFileDescriptor;
import android.os.PowerManager;

import java.io.FileOutputStream;
import java.nio.charset.StandardCharsets;

/**
 * The lookup door: everything this app knows about up to 100 Japanese
 * words, as JSON, for a sister app that caches it — 自由作業盤's 言語島
 * 語彙 asks once per term at import. The contract is
 * {@code docs/sister-app-contract-jisho-lookup.md}; change both together.
 *
 * <h3>Synchronous, into the caller's file</h3>
 *
 * {@code call()} returns only when the answer is written. That keeps this
 * process alive and unfrozen for exactly as long as the work takes — a
 * client in the middle of a provider call holds the provider's process at
 * its own importance — with no foreground service, no notification and no
 * reply broadcast, which matters because the caller runs in a background
 * generation run, perhaps with the screen off.
 *
 * <p>The answer can exceed the 1 MB binder limit, so it goes into a file
 * descriptor the caller opened for writing on a file of its own; the
 * Bundle carries only the status line. A pipe is refused by design: the
 * caller is blocked in this call and could not drain it, so a large
 * answer would deadlock.
 *
 * <p>Who may call is {@link AutomationCallers} — the same pinned names and
 * signing certificates as the data door. The automation-export switch and
 * token do <b>not</b> gate this door: a dictionary lookup exports nothing
 * of 白い熊's.
 */
public class LookupProvider extends ContentProvider {

    static final String METHOD_DESCRIBE = "describe";
    static final String METHOD_LOOKUP = "lookup";

    static final String KEY_RESULT = "result";
    static final String KEY_FD = "fd";
    static final String KEY_REQUEST = "request";

    /** Longest a lookup batch may run before it is abandoned. */
    static final long LOOKUP_TIMEOUT_MS = 90_000;

    /** Longest a describe may take, engine start-up excluded. */
    static final long DESCRIBE_TIMEOUT_MS = 15_000;

    @Override
    public boolean onCreate() {
        return true;
    }

    /**
     * Answers a {@link Bundle} with {@link #KEY_RESULT}: {@code OK:…} or
     * {@code ERROR:…}, returned and never thrown — the data door's rule.
     */
    @Override
    public Bundle call(String method, String arg, Bundle extras) {
        Context context = getContext();
        if (context == null) {
            return result("ERROR:not ready");
        }
        try {
            String refusal = AutomationCallers.verify(context, getCallingPackage());
            if (refusal != null) {
                return result(refusal);
            }
            if (METHOD_DESCRIBE.equals(method)) {
                return result(LookupEngine.call(context, "describe", null,
                    DESCRIBE_TIMEOUT_MS));
            }
            if (METHOD_LOOKUP.equals(method)) {
                return lookup(context, extras);
            }
            return result("ERROR:unknown method: " + method);
        } catch (Throwable t) {
            return result("ERROR:" + t.getClass().getSimpleName()
                + ": " + t.getMessage());
        }
    }

    private Bundle lookup(Context context, Bundle extras) {
        if (extras == null) {
            return result("ERROR:no request");
        }
        String request = extras.getString(KEY_REQUEST);
        if (request == null || request.isEmpty()) {
            return result("ERROR:no request");
        }
        @SuppressWarnings("deprecation")
        ParcelFileDescriptor fd = extras.getParcelable(KEY_FD);
        if (fd == null) {
            return result("ERROR:no descriptor");
        }

        // The caller may be running with the screen off; without a wake
        // lock of our own the CPU can sleep between two items.
        PowerManager power = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
        PowerManager.WakeLock wake = power.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK, "shiroikuma.jisho:lookup");
        wake.acquire(LOOKUP_TIMEOUT_MS + LookupEngine.STARTUP_TIMEOUT_MS);
        try {
            String answer = LookupEngine.call(context, "lookup", request,
                LOOKUP_TIMEOUT_MS);
            if (!answer.startsWith("OK:")) {
                return result(answer);
            }
            byte[] bytes = answer.substring(3).getBytes(StandardCharsets.UTF_8);
            // Our own duplicate, so closing it cannot touch the caller's.
            // AutoCloseOutputStream owns the duplicate and closes it
            // exactly once.
            try (FileOutputStream stream =
                     new ParcelFileDescriptor.AutoCloseOutputStream(fd.dup())) {
                stream.getChannel().truncate(0);
                stream.write(bytes);
                stream.getFD().sync();
            } catch (Exception e) {
                return result("ERROR:descriptor unusable: " + e.getMessage());
            }
            return result("OK:" + bytes.length);
        } finally {
            if (wake.isHeld()) {
                wake.release();
            }
        }
    }

    private Bundle result(String line) {
        Bundle bundle = new Bundle();
        bundle.putString(KEY_RESULT, line);
        return bundle;
    }

    // call() only, like the data door. Refusing loudly beats an empty
    // cursor, which reads downstream as "no data" rather than "wrong door".
    @Override
    public Cursor query(Uri uri, String[] projection, String selection,
                        String[] selectionArgs, String sortOrder) {
        throw new UnsupportedOperationException("lookup is call() only");
    }

    @Override
    public String getType(Uri uri) {
        return null;
    }

    @Override
    public Uri insert(Uri uri, ContentValues values) {
        throw new UnsupportedOperationException("lookup is call() only");
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        throw new UnsupportedOperationException("lookup is call() only");
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection,
                      String[] selectionArgs) {
        throw new UnsupportedOperationException("lookup is call() only");
    }
}
