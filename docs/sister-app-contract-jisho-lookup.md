# Sister-app contract: the 辞書 lookup door

Contract version **1**. First shipped in 白い熊 辞書 **1.6.0+033**.

A sister app hands 白い熊 辞書 (`shiroikuma.jisho`) up to 100 Japanese words and gets back everything
the dictionary knows about each: pitch accent, other written forms, part of speech, senses from
every dictionary, frequency, tags, a kanji breakdown, example sentences and a conjugation table.
Built for 自由作業盤’s 言語島 語彙: it asks once per term at import, caches the answer, and never wakes
辞書 while 白い熊 browses.

Implementation: `android/app/src/main/java/shiroikuma/jisho/LookupProvider.java` (the door),
`LookupEngine.java` (the headless engine), `lib/src/utils/misc/jisho_lookup.dart` (the answer),
`jishoLookupMain` in `lib/main.dart`. Change this file together with them.

## 1. Discovery without waking 辞書

The application element carries

```xml
<meta-data android:name="shiroikuma.jisho.lookup.contract" android:value="1" />
```

Read it with `PackageManager.getApplicationInfo("shiroikuma.jisho", GET_META_DATA)` (add
`MATCH_UNINSTALLED_PACKAGES | MATCH_DISABLED_COMPONENTS` to see a frozen 辞書). Absent or not
installed → show “辞書: 未対応” and do not call. This costs nothing and cannot hang. The caller needs
`<package android:name="shiroikuma.jisho" />` in its `<queries>`.

## 2. The door

| Item | Value |
| --- | --- |
| Authority | `shiroikuma.jisho.lookup` |
| URI | `content://shiroikuma.jisho.lookup` |
| Kind | `ContentResolver.call()` only. `query`/`insert`/`update`/`delete` throw. |
| Methods | `describe`, `lookup` |
| Caller | Pinned by package name **and** signing-certificate SHA-256 (`AutomationCallers.java`, the same pins as the 保存復元 data door): `shiroikuma.jiyusagyoban`, `shiroikuma.oyokanri`. Anyone else gets an `ERROR:caller …` line. |
| Not gated by | The 自動化 export switch and token in 辞書’s UI settings. A lookup exports none of 白い熊’s data. |

Every call returns a `Bundle` whose `"result"` string is either `OK:…` or `ERROR:<reason>`. Errors
are returned, never thrown across the binder.

**`call()` is synchronous and slow.** It returns only when the work is done: a cold start (no 辞書
process, or its lookup engine idle for over 60 s) takes about 2–10 s to bring the database up, after
which each item takes about 20–200 ms. Always call from a background thread, never the main thread.
The provider call itself holds 辞書’s process at the caller’s importance, so no foreground service or
notification is involved, and 辞書 takes its own partial wake lock for the duration. It works with the
screen off.

### 2a. `describe`

```kotlin
val b = resolver.call(Uri.parse("content://shiroikuma.jisho.lookup"), "describe", null, null)
// b.getString("result") == "OK:{…json…}"
```

```json
{
  "lookup_version": 1,
  "version_name": "1.6.0",
  "version_code": 106002033,
  "max_items": 100,
  "japanese_installed": true,
  "examples_installed": true,
  "dictionaries": [
    {"name": "Jitendex.org [2026-10-03]", "enabled": true},
    {"name": "Kanjium Pitch Accents", "enabled": true},
    {"name": "Wiktionary (de)", "enabled": false}
  ]
}
```

`version_code` is Android’s packed `versionCode` (`X*1e8 + Y*1e6 + Z*1e4 + N`, plus 2000 for the arm64 split: 1.6.0+033 → `106002033`). Compare versions by it, or read `version_name` for display.
`enabled` means the dictionary is used for Japanese (not hidden for `ja`, and its primary language is
Japanese or unset). Only enabled dictionaries contribute to answers. The list is in 白い熊’s
dictionary order.

### 2b. `lookup`

The caller creates a file of its own (in its cache directory), opens it **for writing**, and passes
the descriptor along with the request:

```kotlin
val file = File(cacheDir, "jisho-lookup.json")
val pfd = ParcelFileDescriptor.open(file,
    ParcelFileDescriptor.MODE_WRITE_ONLY or ParcelFileDescriptor.MODE_CREATE
        or ParcelFileDescriptor.MODE_TRUNCATE)
val extras = Bundle().apply {
    putString("request", requestJson)
    putParcelable("fd", pfd)
}
val b = pfd.use {
    resolver.call(Uri.parse("content://shiroikuma.jisho.lookup"), "lookup", null, extras)
}
// b.getString("result") == "OK:<byte count>"  → read file as UTF-8 JSON
```

**Not a pipe.** The caller is blocked in `call()` and cannot drain a pipe, so an answer larger than the
pipe buffer would deadlock. Use a regular file. 辞書 writes into a duplicate of the descriptor,
truncates the file first, `fsync`s, and closes only its duplicate; the caller closes its own.

`OK:<n>` means exactly `n` bytes of UTF-8 JSON were written. On any `ERROR:` the file contents are
undefined. Do not read it.

#### Request

```json
{
  "language": "ja",
  "items": [
    {"term": "犬", "reading": "いぬ"},
    {"term": "食べる", "reading": ""},
    {"term": "ありがとう", "reading": "ありがとう"}
  ]
}
```

- `language`: `"ja"` only (omitted means `"ja"`).
- `items`: 1–100 objects. `term` is required. `reading` is hiragana and may be empty; katakana is
  accepted too, since both sides are folded to hiragana before comparing.
- Lookup is **exact**: the headword must equal `term`. With a reading, the heading’s reading must
  match. With no reading, the first heading for that headword in 白い熊’s dictionary order is used.
  Inflected forms (食べた) and prefixes are *not* resolved to their dictionary form. Send the
  dictionary form.

#### Answer

```json
{
  "lookup_version": 1,
  "version_name": "1.6.0",
  "items": [ <one object per request item, in request order> ]
}
```

A miss is explicit:

```json
{"term": "犬犬", "reading": "", "found": false}
```

A hit:

```json
{
  "term": "犬",
  "reading": "いぬ",
  "found": true,
  "headword": "犬",
  "headword_reading": "いぬ",
  "pitch": [2],
  "forms": ["狗", "イヌ"],
  "pos": ["n"],
  "glosses": [
    {"dictionary": "Jitendex.org [2026-10-03]",
     "senses": ["dog (Canis (lupus) familiaris)", "squealer; rat; snitch; informer; …", "…"]},
    {"dictionary": "JMdict [2026-10-01]", "senses": ["dog (Canis (lupus) familiaris)", "…"]}
  ],
  "frequency": 1462,
  "frequency_dictionary": "JPDBv2㋕",
  "tags": [{"name": "★", "notes": "priority form"}],
  "kanji": [
    {"char": "犬", "meanings": ["dog"], "on": ["ケン"], "kun": ["いぬ", "いぬ-"],
     "strokes": 4, "grade": 1, "jlpt": 4, "frequency": 1203, "newspaper_rank": 1326}
  ],
  "examples": [
    {"ja": "犬が吠えている。", "en": "The dog is barking."}
  ],
  "conjugation_class": "v1",
  "conjugation": [
    {"form": "Non-past", "plain": "食べる", "plain_negative": "食べない",
     "polite": "食べます", "polite_negative": "食べません"}
  ]
}
```

| Field | Type | Meaning |
| --- | --- | --- |
| `term`, `reading` | string | Echo of the request item, verbatim (trimmed). |
| `found` | bool | Whether an exact heading exists in an enabled dictionary. |
| `headword`, `headword_reading` | string | The heading as 辞書 stores it. The reading may be katakana, and is empty for a kana-only word stored without a reading. |
| `pitch` | int[] | Downstep numbers (0 = 平板), at most 2 distinct, from the pitch dictionaries (Kanjium) in 白い熊’s order. Empty when none is known. |
| `forms` | string[] | Other written forms, from the first dictionary that lists them (Jitendex). May be empty. |
| `pos` | string[] | Part-of-speech and usage codes as the dictionaries give them: JMdict entry tags plus Jitendex’s part-of-speech span codes (`n`, `v5k`, `vt`, `adj-i`, `uk`, …). Heading tags are reported separately, under `tags`. |
| `glosses` | object[] | One object per enabled dictionary with any content, in 白い熊’s order. `senses` are plain strings: for an English dictionary each sense’s glosses joined with `"; "`; for a dictionary without English glosses (a monolingual one) each definition flattened to its text. Structured-content markup, examples and notes inside definitions are **not** included for English dictionaries. |
| `frequency` | int \| null | Rank from the top frequency dictionary (JPDB), first figure only, as the result card shows it. Lower is more common. |
| `frequency_dictionary` | string \| null | Which dictionary gave `frequency`. |
| `tags` | object[] | The heading’s own tags, `{name, notes}`, deduplicated (★, P, JLPT tags where a dictionary carries them). |
| `kanji` | object[] | Each distinct kanji of the headword (々 skipped), in order. `meanings`/`on`/`kun` come from KANJIDIC, as do `strokes`/`grade`/`jlpt` (int or null; `jlpt` is the old 4-level KANJIDIC value). `frequency` is the JPDB kanji rank (null without that dictionary). `newspaper_rank` is KANJIDIC’s newspaper frequency. A kanji with no KANJIDIC row comes back with empty arrays and nulls. |
| `examples` | object[] | Up to 10 `{ja, en}` pairs from the Tanaka corpus, shortest first. Empty when example sentences are not downloaded (`describe` → `examples_installed`). |
| `conjugation_class` | string | Present only for a verb or i-adjective: the JMdict class used (`v1`, `v5k`, `vs`, `adj-i`, …). |
| `conjugation` | object[] | Present only with `conjugation_class`: 辞書’s generated table, one row per form in display order, each `{form, plain, plain_negative, polite, polite_negative}`. A cell may be an empty string where a form has no such variant. |

New fields may be added without bumping `lookup_version`. Ignore unknown keys.

## 3. Errors

| `result` | Meaning | What to do |
| --- | --- | --- |
| `ERROR:caller unknown` / `caller not permitted: <pkg>` / `caller uid mismatch` / `caller signature unreadable` / `caller signature mismatch` | Pinned-caller check failed. | A signing key changed or the caller is not in the pin list; this is fixed in 辞書’s `AutomationCallers.java`. |
| `ERROR:no request` / `ERROR:no descriptor` | Extras missing. | Caller bug. |
| `ERROR:request is not an object` / `items missing` / `too many items: N > 100` / `language not supported: X` | Bad request JSON. | Caller bug; split batches at 100. |
| `ERROR:japanese not installed` | 辞書 has no Japanese language set up. | Show “辞書: 日本語なし”. |
| `ERROR:startup failed: …` | The headless engine could not bring the database up. | Retry once later; report verbatim. |
| `ERROR:timeout starting lookup engine` | No engine within 30 s. | Retry once. |
| `ERROR:timeout after 90000 ms` | The batch took over 90 s; the engine is discarded. | Retry with a smaller batch. |
| `ERROR:descriptor unusable: …` | Writing into the caller’s descriptor failed. | Check the file was opened for writing and is not a pipe. |
| `ERROR:<other>` | An unexpected failure, as text. | Report verbatim. |

`call()` itself can still throw on the caller’s side if 辞書 is not installed, is frozen or disabled
(`IllegalArgumentException: Unknown authority` / `SecurityException`), or if its process dies
mid-call (`DeadObjectException`). Treat any of these as “辞書: 未対応” or a retryable failure.

## 4. Timeouts the caller should use

- `describe`: allow **45 s** (a cold engine start plus the answer).
- `lookup`: allow **130 s** per batch of 100 (30 s start, 90 s work, margin).
- `ContentResolver.call` has no timeout of its own, so run it on a worker thread and give up on the
  result if your deadline passes. The call cannot be cancelled from the caller’s side. 辞書 abandons
  the batch at its own 90 s limit.
- Calls are serialised inside 辞書: a second concurrent call waits for the first.

## 5. EMUI and cold-start notes (Mate XT, GRL-LX9)

- **Frozen 辞書.** If 白い熊 has frozen 辞書 (EMUI app launch management / a freezer), the provider
  cannot be reached. Discovery (§1) still works. The call throws. Report it, do not retry in a loop.
- **No logcat.** EMUI drops non-ERROR log lines. 辞書 logs engine start/teardown at ERROR level under
  tag `LookupEngine`. Everything else surfaces only through the `ERROR:` lines.
- **Warm engine.** After a call, 辞書 keeps the headless engine for 60 s. Send batches back to back to
  pay the start-up once. Between batches EMUI may still kill the idle 辞書 process. The next call then
  simply cold-starts.
- **辞書 open in the foreground at the same time** is fine: the lookup engine is a second engine in the
  same process sharing the same database.
- **Results reflect 白い熊’s settings**: hiding a dictionary for Japanese or reordering dictionaries in
  辞書 changes later answers. Cached answers do not update themselves.
