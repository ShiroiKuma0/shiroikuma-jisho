package shiroikuma.jisho;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

/**
 * The 日本語辞書 entry point: a second launcher icon and a second
 * text-selection ("PROCESS_TEXT") entry, both opening the dictionary in
 * Japanese whatever language the app is set to — so a word from a Japanese
 * web page can be looked up while a German book stays open.
 *
 * <p>A trampoline rather than an activity-alias because an alias cannot add
 * extras: it forwards to {@link MainActivity} as {@link #ACTION_OPEN_DICTIONARY}
 * with {@code language=ja} and the selected text, if any, as {@code query},
 * then finishes without drawing. MainActivity is singleTask, so the dictionary
 * opens on top of whatever the app already shows; closing it sends the app's
 * task to the back, returning to the app the lookup came from.
 *
 * <p>The forwarded action is public, so Tasker can fire it at MainActivity
 * directly with any {@code language} code.
 */
public class JapaneseDictionaryActivity extends Activity {
    static final String ACTION_OPEN_DICTIONARY = "shiroikuma.jisho.action.OPEN_DICTIONARY";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent source = getIntent();
        String query = "";
        if (source != null && Intent.ACTION_PROCESS_TEXT.equals(source.getAction())) {
            CharSequence text = source.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT);
            if (text != null) {
                query = text.toString();
            }
        }

        Intent forward = new Intent(this, MainActivity.class);
        forward.setAction(ACTION_OPEN_DICTIONARY);
        forward.putExtra("language", "ja");
        forward.putExtra("query", query);
        forward.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(forward);

        finish();
    }
}
