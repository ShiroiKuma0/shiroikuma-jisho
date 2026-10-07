<div align="center">

<img src="assets/meta/icon.png" width="120" alt="白い熊の辞書 icon" />

# 白い熊 辞書

**An immersion language-learning suite: video player, audio-synced ebook reader, dictionary and Anki card factory in one app.**

A fork of [arianneorpilla/jidoujisho](https://github.com/arianneorpilla/jidoujisho) with **major additions**: a full offline Japanese dictionary (in-app dictionary downloads, English search, kanji page with stroke order, conjugation tables, example sentences, word lists to CSV and Anki), on-device OCR for Blu-ray subtitles and scanned PDFs, five new languages, an audio-synced reader with SRT subtitles and Tasker control, 言語島 sentence-island study imported from its sister app, a dual-language translation split view, one shelf for every imported book, per-book appearance settings, cross-device backup, an e-ink-friendly UI, and **not one tracker in the APK**.

Installs **side-by-side** with jidoujisho (app id `shiroikuma.jisho`).

**📥 Latest release: [`1.6.0+001`](https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/latest)** — [all releases & APK downloads »](https://github.com/ShiroiKuma0/shiroikuma-jisho/releases)

</div>

---

## 🔍 On-device OCR — study what has no text
PP-OCRv6 under ONNX Runtime, bundled and fully offline, turns image-only media into tappable study material — Apache-2.0 for both code and model weights, and it registers nothing in the manifest, so a tracker scan of the APK reports **zero**. Recognition of 縦書き is told which blocks are vertical rather than guessing from their shape, so a wide speech bubble of short columns is no longer read as horizontal text. **Blu-ray PGS subtitles**: one tap in the player's track menu OCRs the bitmap track into a real subtitle file (saved beside the video, auto-loaded forever after) with dictionary tap-lookup and Anki export — and in pause-per-subtitle mode the original bitmap is shown alongside the recognised text, so OCR errors are caught at a glance. **Scanned PDFs**: the "Scanned PDF" reader source rasterises and OCRs every page on-device into a mokuro-style volume — the original page image with an invisible, tappable text overlay.

---

## 🎨 白い熊 辞書 UI — the whole look, settable live
A dedicated UI settings page (long-press the menu icon) in the family style of the sister apps: every colour (RGBA sliders with prior-colour presets), external fonts rendered in their own glyphs, text scale and weight, dialog and button borders down to zero — all previewed live by the running app itself, on a black/yellow default made for e-ink. One-zip export/import of every setting plus the app's generated artifacts, and a token-gated 保存復元 automation interface so 白い熊 自由作業盤 backs the app up headlessly alongside its sisters.

---

## 🌍 Five more languages
German, Polish, Russian, Ukrainian and Czech added on top of upstream's Japanese and English — full dictionary lookup, reader and card-export support in each, with per-language TTU reader instances.

---

## 🎧 Audio-synced reading with external control
A reader audio toolbar plays an audiobook alongside the ebook, synced by SRT subtitles: seek by subtitle, replay, chapter navigation, condensed and auto-pause (shadowing) playback modes. Seven broadcast intents in the `shiroikuma.jisho.action.PLAYBACK_*` namespace let Tasker or any automation tool drive playback — next/previous/replay subtitle, play/pause, chapter navigation, mode cycling — without touching the screen. The toolbar's buttons are individually hideable so it fits narrow screens.

---

## 📚 One shelf for every book
**All books** merges everything already imported — EPUBs held by the ッツ reader, OCR'd scanned PDFs, mokuro manga volumes — into a single shelf ordered by what was read last, each tile badged with the source it came from and opening in that source. **All videos** does the same for local files and downloaded YouTube. The active source is named in a bold bordered pill in the middle of the bar, so which reader you are in is never a guess, and the pill is itself the source picker. The ッツ library is cached, so the tab paints instantly instead of waiting for a hidden webview to boot the entire reader; a scan that stalls now falls back to the cache instead of spinning forever. Books can be deleted outright — record, bookmarks, and every per-book setting — so a re-import comes back clean.

---

## 📖 Dual-language reader
Open a translation book in a split view next to the original and keep both in sight while reading. Per-book, per-pane appearance settings: writing mode (Japanese defaults to vertical), font size, font color, background, weight, margins and line spacing — every book remembers its own. Two editions of the same novel carry the same title in their metadata, and ッツ identifies books by title alone — so importing the second one used to silently replace the first, taking its reading position with it. Here they import side by side, the newcomer labelled by the language it declares (`Lázár` and `Lázár [cs]`), without the EPUB files being touched.

---

## 📺 Dual subtitles in the player
Show a secondary (translation) subtitle track on top of the primary one, with independent font, color, weight and vertical-position control for each. Keyboard playback control included.

---

## 📥 YouTube offline study videos
One tap in [shiroikuma-jiyudoga](https://github.com/ShiroiKuma0/shiroikuma-jiyudoga) ("Study in jisho") downloads a YouTube video with generated subtitles into a study folder and opens it here immediately — offline playback with per-line replay and tap-word dictionary. The "YouTube offline" player source lists the whole study library with resume positions.

---

## 🏝️ 言語島 islands from 自由作業盤
「辞書で学ぶ」in [白い熊 自由作業盤](https://github.com/ShiroiKuma0/shiroikuma-jiyusagyoban)'s 言語島 editor hands a whole sentence island to this app: one joined audio file of every sentence in the island, voiced by 白い熊 音声, with its subtitles beside it — opened straight into the player, where each sentence is tappable for dictionary lookup and exportable to Anki. Subtitle-pause playback stops on the sentence boundary rather than a quarter-second past it, and the subtitle seek buttons step sentence by sentence, so an island is studied one sentence at a time without touching the scrub bar.

---

## 🔁 Cross-device backup and restore
Everything — dictionaries, reading positions, books, preferences, browser bookmarks, mokuro catalogs — exports to a single portable ZIP bundle and imports on another device, surviving package re-signing. Audio paths remap automatically on the destination device.

The same export runs **headlessly, driven from outside the app**, so a backup tool can capture 白い熊 辞書 along with everything else on the phone and put it back on a wiped one — without the app ever being opened. Callers are identified by the system rather than by a shared secret: an exact package name, the uid the kernel reports, and a pinned signing certificate. A long export can be **cancelled from where it was started**, and unwinds at a write boundary leaving no partial archive behind.

---

## 🖥️ E-ink friendly
A yellow-on-black high-contrast theme, wrapping menus, and UI-fit work targeted at narrow e-ink devices (developed against a Boox Palma 2 Pro). Panels are drawn with a visible edge rather than a shade of grey — the reader's pull-up sheets carry a yellow line along their top, since a black sheet over a black page has no boundary an e-ink screen can show. EPUB import bypasses the in-webview file chooser that crashes Boox firmware.

---

## 🐻 A Japanese dictionary that stands on its own
Everything a phone dictionary like Takoboto does, offline. **Download dictionaries** fetches Jitendex, JMdict, KANJIDIC, pitch accent, frequency lists, the Tatoeba example sentences and KanjiVG stroke order from inside the app, already-installed ones marked as such. **Search in English** — “eat” finds 食べる — from a gloss index built once at import. Conjugated words are recognised with **Yomitan's current deinflection rules**, and each language keeps its own dictionary order, set by dragging. Results are **compact cards**: one header line with reading, other spellings and frequency, a chip per dictionary, inline glosses, pinch to resize. Beside the dictionary chips, **活用** shows a full conjugation table for any verb or i-adjective and **例文** lists example sentences using the word, marked as it is written. Tap any kanji for its **kanji page** — KANJIDIC readings, meanings, stroke count, grade, JLPT level and frequency, with the strokes drawn in order — or **find a kanji by its radicals**. **Word audio** plays offline from a local AnkiConnect-Android audio database, falling back to text-to-speech. The **★** puts a word in named **word lists**, which export as CSV or TSV or go to Anki as a deck of cards in one step.

---

## 📘 Dictionary upgrades
Every Japanese word in an entry is tappable for recursive lookup with clean back/close-all navigation; word-boundary detection on tap works in all supported languages; dictionaries can be edited, reordered and searched; font size adjusts live with an edge swipe (toggleable). Typography is settable per role — separate font and size for the heading, for definitions in the target language, and for glosses in another one — with the role decided from each entry's own text, since dictionary formats record which language a dictionary applies to but never which language it explains it in.

---

## Built on jidoujisho
A fork of [arianneorpilla/jidoujisho](https://github.com/arianneorpilla/jidoujisho) (app id `shiroikuma.jisho`, so it coexists with the official build). jidoujisho is a video player, reading aid, dictionary and card-creation toolkit built for language learners — this fork stands on that foundation and its excellent upstream ecosystem: ッツ Ebook Reader, Mokuro, Yomichan dictionaries, AnkiDroid export. The code remains under the [GNU General Public License 3.0](LICENSE).

## Building
```bash
git clone https://github.com/ShiroiKuma0/shiroikuma-jisho.git
cd shiroikuma-jisho
# Requires JDK 17+ (Gradle 9.1.0 / AGP 9.0.1) and Flutter 3.44.x (Dart 3.12).
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 && export PATH="$JAVA_HOME/bin:$PATH"
flutter build apk --split-per-abi --release
# APK: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```
