# Changelog

All notable user-visible changes to **白い熊の辞書 (shiroikuma-jisho)** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Offline word audio.** Two new audio sources: **Text-to-Speech**, the
  phone's own Japanese voice (offline once a Japanese voice is installed),
  which speaks the word's reading so kanji are never misread; and **Local
  Audio**, which plays recordings from a local audio collection — the
  `android.db` that local-audio-yomichan builds for AnkiConnect Android,
  read from `/storage/emulated/0/AnkiconnectAndroid/android.db` by default
  (changeable in the dictionary settings), best recordings (NHK) first.
  The play button now falls back to local audio and then the phone's
  voice when the export profile's audio sources find nothing, so every
  word can be heard without a network. Both can also fill a card's audio
  field.

- **A compact result card: one header line and dictionary tabs.** Each
  result now opens with a single line — the headword, its reading with
  the pitch drawn on it and the accent number, and small markers for the
  word's tags (★…) and its frequency rank — with the quick actions at its
  end. Below it, one chip per dictionary in your order; tap a chip to show
  that dictionary's definitions, long-press it for its own actions
  (formerly the ⋮ by the dictionary name). The first dictionary that is
  not set to collapsed is shown by default. The separate frequency, pitch
  and per-dictionary blocks are gone, and the definitions themselves are
  tightened: a sense's glosses run on one line joined by “;”, Jitendex's
  forms read “犬、狗、イヌ”, examples sit a step smaller with a dimmed
  translation, the blank lines around every list are gone, and indents are
  minimal — part of speech and ①②③ sit flush left, only examples and
  notes step in. The header line also lists the word's other spellings
  (犬、狗、イヌ) from the dictionary's forms list, and example sentences,
  notes and cross-references sit in boxes with a thin coloured rule, the
  looked-up word in bold. An English
  search now shows every dictionary's entry for each word it finds, not
  only the one whose English matched.

- **Pinch to resize dictionary results.** Pinch anywhere on a result list
  — the dictionary tab or a pop-up over the reader or player — to make the
  text larger or smaller. Headwords, furigana, definitions and
  translations scale together, the size is shown while you pinch, and it
  is remembered, just like the existing left-edge swipe.

- **Search in English to find Japanese words.** Typing “eat” now finds
  食べる, 食う and 口にする; “give up” finds 諦める; “thank you” finds
  ありがとう. Matches are ranked by how closely a meaning fits (the whole
  meaning first, then meanings that start with your words, then ones that
  merely contain them), then by how early that meaning is listed, then by
  word frequency. A query that also reads as romaji is searched both ways:
  “sake” shows 酒 by its reading and by its meaning, with whichever matches
  the whole query first. Works with any dictionary that has English
  meanings, such as Jitendex or JMdict. A dictionary is indexed once, as
  part of its import; one installed earlier shows “Index for English
  search” in its ⋮ menu in the dictionary list, which builds the index
  behind a progress dialog (a few minutes for Jitendex) and then
  disappears.

- **Download dictionaries from inside the app.** The dictionary menu has a
  new “Download dictionaries” button, and a fresh install offers the same
  list right after first-time setup. Tick what you want and the app fetches
  each Yomitan zip from its maintainer and imports it: Jitendex, JMdict
  (English), KANJIDIC (English), Kanjium pitch accents, JPDB frequency and
  JMnedict. Recommended ones come pre-ticked, sizes are shown, and
  dictionaries already imported are listed as “installed” without a
  checkbox, so only what will actually be fetched is ticked; an older
  import titled just “JMdict” counts as installed too. Nothing is bundled,
  so the APK stays the same size. Only offered while the target language
  is Japanese.
- **Each language keeps its own dictionary order, set by dragging.** The
  dictionary menu lists the dictionaries shown for the current language
  first, each with a drag handle (or long-press the row), and the
  dictionaries hidden for that language below them under “Hidden for …”.
  Dragging only reshuffles the shown ones, so ordering Japanese
  dictionaries no longer has to work around the Czech or French ones,
  and the list scrolls by itself while a row is dragged to its edge. The
  order decides which dictionary's definitions come first under a word.

### Changed

- **Text shared to the app is looked up in the dictionary.** Sharing a
  word or sentence from another app now opens it as a dictionary search,
  like “Look up” in the text-selection menu, instead of the Anki card
  creator with the text as its sentence. A card can still be made from the
  result. Shared links behave as before.

- **Conjugated words are recognised the way current Yomitan does it.** The
  rules for turning 食べさせられた, 書かれました or しなければ back into
  食べる, 書く and する are now Yomitan's current set (55 kinds of
  inflection, 889 rules) instead of a copy of old Yomichan's, and only
  real dictionary forms are looked up.
- **Japanese searches skip dictionaries you hid for Japanese.** Their hits
  used to take up the ten result slots and then be dropped from the
  display, pushing real matches off the list.

- **The project is now called shiroikuma-jisho everywhere.** The GitHub
  repository moved to `ShiroiKuma0/shiroikuma-jisho` (old links redirect),
  and the files the app writes to `/sdcard/tmp/` follow the new name:
  backups are `shiroikuma-jisho-backup_<stamp>.zip` and diagnostic logs
  `shiroikuma-jisho-<kind>_<stamp>.log`. Bundles exported under the old
  `shiroikumanojisho_` names still import.

### Fixed

- **Tapping a “See also” link opens the word it points to.** A link with
  furigana, such as 相撲取り, searched its text with the readings mixed in
  (“相撲すもう取とり”) and found nothing useful. Links now search their
  real target. A word's header line also no longer repeats tags such as
  ★, ichi and news2k when two dictionaries give the same ones.

- **Jitendex, JMdict and other Yomitan dictionaries look the way they are
  meant to.** Definitions came out as several nested bulleted lists with
  stray “•” and “▪” markers, tags such as “derogatory” and “kana” ran
  together, and the kanji of example sentences were missing (“はえるをがる”
  instead of 彼女は吠える犬を怖がる with its readings). The dictionary's own
  stylesheet is now applied — Jitendex shows ＊ part-of-speech groups,
  ①② numbered senses, unbulleted glosses and coloured tag badges —
  example sentences show their kanji with furigana, and JMdict keeps its ◦
  bullets, 📝 notes and ➡ cross-references.

- **The Dictionary tab's lookup history survives a restart.** It was kept
  only in memory, so every launch showed “History is empty” while the
  search box still offered the earlier searches. The looked-up words are
  now saved and searched again at startup; removing a dictionary refreshes
  them instead of emptying the history.

- **The Stash no longer forgets words.** It was stored with the search
  histories and trimmed like them, so once it held more than 60 words,
  adding one silently dropped the oldest. It now keeps everything until
  you remove it.
- **Media history no longer loses 41 entries at a time.** When a media
  type's history went past its 100-entry limit, the trim used the search
  history's limit of 60 to count the surplus and deleted the 41 oldest
  entries instead of one.

## [1.5.0+081] - 2026-10-01

### Added

- **Study a 言語島 island from 白い熊 自由作業盤.** A new Android intent,
  `shiroikuma.jisho.intent.action.STUDY_AUDIO`, opens an island's joined
  audio file in the player with its subtitles already loaded, so every
  sentence can be looked up in the pop-up dictionary and sent to Anki the
  same way a video can. 自由作業盤's 「辞書で学ぶ」 button fires it with two
  extras — `path`, the absolute path of the island's `.ogg`, and `title`,
  the island's name — and the app finds the island's same-name `.srt`
  beside the audio by itself. Islands land in the "Local video files"
  history like any other picked file, so they can be resumed from there.
  An island whose audio file has gone missing reports "Study audio file
  not found" rather than opening an empty player.

### Fixed

- **Fixed the player going deaf mid-session when subtitles were set to
  "None".** The subtitle track that "None" resolves to was never parsed,
  and every cue lookup against an unparsed track raises an error. That
  lookup is the first thing the player does on each of its four-times-a-
  second updates, so the error aborted the whole update — and with it the
  position tracking, the current-sentence tracking, Subtitle Pause
  Playback, the subtitle display and the resume-position bookkeeping — for
  the remainder of the session, with nothing shown to say so. The same
  window could open briefly at any point where a track is still loading,
  which on a freshly opened file happened in roughly one open in three.
  The track is now parsed before it can be selected, and a cue lookup can
  no longer abort an update.

- **A local file no longer plays its first moment aloud as the player
  opens.** The player deliberately starts playing for an instant so VLC
  can parse the file's tracks, then pauses — but it waited for the
  reported position to move past zero before doing so, and a position
  arrives only about four times a second, so a file opening at its start
  played a few hundred milliseconds of its first sentence out loud. That
  wait exists to confirm a resume seek has applied, which a file opening
  at zero has none of, so it now pauses on the first moment of playback
  instead. A file resuming part-way is unchanged, beyond being rewound
  onto its saved position rather than a tick past it.

- **The player's subtitle seek buttons now land on the subtitle they
  aim at.** Both computed their target in whole seconds, so they arrived
  up to a second away from the cue's start — the back button at the tail
  of the *previous* sentence rather than the start of the current one,
  which took two presses to reach what one should have found, and the
  forward button still inside the sentence being left. They now seek in
  milliseconds, landing on the cue's own start. Which cue each button
  picks is unchanged.

- **Subtitle Pause Playback Mode now stops on the cue boundary, not a
  quarter-second past it.** The player used to notice a subtitle had
  ended only on the next position report it got from libVLC, and libVLC
  reports a position about four times a second — measured 260 ms apart
  on a mono Ogg Opus stream, and up to 500 ms apart on an MP4. Every
  stop therefore ran past the end of the sentence by up to that much,
  plus whatever the audio device had buffered, which on a 言語島 island
  with ~200 ms of silence between sentences meant hearing the start of
  the next sentence every time. The stop is now aimed at the cue end
  with a timer and the playhead is then parked on the cue end, so the
  next sentence is also heard whole when you resume instead of missing
  its first fraction of a second. Jumping the playhead in this mode — Prev/Next subtitle, the
  transcript, the scrub bar, a double-tap seek — also no longer stops
  playback: the pause now fires only when a subtitle was actually played
  through to its end, rather than on any change of the current subtitle. This is the same fix the reader's
  audio toolbar already had; the player never received it. It applies
  to every file the player opens, not only islands.

## [1.5.0+057] - 2026-09-09

### Changed

- **The app now has no trackers at all.** Text recognition was provided
  by Google ML Kit, which merged two components into the app's manifest
  — `MlKitInitProvider` and `MlKitComponentDiscoveryService` — that
  started themselves every time the app launched, whether or not you
  ever used OCR. It has been replaced by PP-OCRv6, which is Apache-2.0
  for both code and model weights and registers nothing in the manifest.
  A tracker scan of this build reports zero.
- **OCR is now noticeably better on vertical Japanese.** The new engine
  runs entirely on-device, like the old one, and covers the same three
  places: OCR of image-based (PGS) subtitle tracks in the player, the
  one-time import of a scanned PDF, and the "OCR test (image)" item in
  the settings menu. Recognition of 縦書き improved most — the engine
  is told which blocks are vertical rather than guessing from their
  shape, so a wide speech bubble of several short columns is no longer
  mistaken for horizontal text, and a trailing 「。」 that the detector
  cuts loose from its column is rejoined instead of being read on its
  own. Reading order within a block now runs right-to-left for tategaki.
- **Fixed backups that could not be read back at all.** Every backup
  this app has ever written was unreadable on Android, and a restore
  failed within seconds of starting. The archive's index was written
  with a 64-bit trailer that only belongs in archives too large for the
  ordinary 32-bit one; Android's zip reader ignores that trailer unless
  the ordinary index says to look for it, and then finds the index 76
  bytes from where it expected. The trailer is now written only when it
  is genuinely needed, so an archive of any size opens. Desktop tools
  always accepted these archives, which is why the fault took so long
  to find — it was only ever visible to the reader on the phone.
  **A backup taken with an earlier build cannot be restored; take a
  fresh one with this build.**
- **The font you set for a book is now used after a restore.** An
  imported font needs two things on the phone: the file, and a small
  index recording which font family that file provides. The per-book
  setting stores the family name — "Source Han Serif JP" — while the
  file on disk is named something else entirely, so the index is the
  only link between the two. Neither the file nor the index was ever
  backed up, and restoring only the file was not enough: the font sat
  on the phone unused while the setting still named it, which looked
  exactly like the font not having been restored at all. Both now
  travel, and so do the fonts imported from the settings page for the
  app's own interface, which are kept separately. Fonts that ship with
  the app were never affected, so only imported ones showed the fault.
  Carried both by 白い熊 応用管理, under the existing "Imported fonts"
  item so nothing needs re-selecting, and by the in-app cross-device
  export, which had never included fonts at all.
- **Book covers are restored.** Each book's cover is kept as a file on
  the phone, in a folder no backup included, so a restored library
  showed its books with no covers until a library scan happened to
  rebuild them. Those files are now part of the backup.
- **A cover image you chose by hand is no longer lost.** Replacing a
  media item's thumbnail with your own picture stored that picture in a
  folder no backup included, while the matching renamed title — being a
  setting — was preserved. A restored library therefore kept every
  rename and silently reverted every custom cover. Those images are now
  part of both the backup and the in-app cross-device export.
- **Restored books now open, and keep their pictures.** The backup
  saved each book's text and cover but silently threw away every image
  and font embedded inside it, because those are held in a form that
  vanishes when converted to text. What was written in their place was
  worse than nothing: the reader tried to build a picture out of an
  empty placeholder, gave up, and showed a blank page instead of the
  book. Books restored from an older backup will now open too — minus
  the pictures, which that backup never contained. Take a fresh backup
  to get those back.
- **Restoring a library no longer loses the first language's books.**
  The restore began writing books as soon as the reader's page had
  loaded, which is a few seconds before the reader has finished
  preparing its own storage. Every book for the first language went
  into a store that did not exist yet and was lost, while later
  languages — by then writing into a warm reader — restored normally.
  That is why a restore could come back with the German books present
  and the Japanese ones missing. The restore now waits for the reader
  to be genuinely ready, and says so in its log if it never is.
- **A failed backup or restore now leaves a log you can retrieve.**
  The log was written to shared storage, and when that is not
  permitted — which is exactly the case during a restore, since the
  app has never been opened to grant anything — it fell back to a
  private folder no tool can reach. It now falls back to the app's own
  folder under `Android/data`, which needs no permission and can be
  pulled off the phone.
- **Backups are now readable by any zip tool, not just a seeking one.**
  A second fault in the same writer recorded every entry's uncompressed
  size as zero in the small record that follows the entry's data, by
  writing that record in the 64-bit layout for entries that need the
  32-bit one. Our own restore never noticed, because it takes sizes
  from the archive's index instead — but a tool that reads an archive
  straight through, rather than jumping to the index, would reject the
  backup as corrupt. The sizes there now agree with the index.
- **The restore no longer unpacks the archive one file at a time.** It
  now extracts in a single pass, skipping anything not being restored,
  and then moves each restored folder into place with one operation
  instead of copying its files individually. A real restore was making
  over ten thousand separate extractions, and that machinery is where
  every failure today happened — it crashed on one archive, then sat
  motionless on a 4 GB file, then on a 1.7 GB one, each time with the
  app idle and unable to say why. The extractor now used has not failed
  once at any size. Restores should be dramatically faster as well as
  more reliable.
- Progress now shows the exact byte count with thousands separators
  rather than a rounded size. "1.57 GB" stays on screen unchanged for
  minutes during a large step, which looks exactly like being stuck; a
  digit moving anywhere in `1,209,620,352` proves it is not.
- **The progress line keeps moving, and says something when it repeats.**
  Extraction now reports its own percentage as it goes, so the long
  silences that 白い熊 応用管理 filled with "waiting for the app" have
  nowhere to appear; and when a step genuinely has nothing new to say,
  the line carries the elapsed time rather than repeating itself.
- **A stalled backup or restore now reports itself in time to be
  heard.** The guard meant to turn a stuck archive operation into a
  clear error was set to thirty minutes, but 白い熊 応用管理 gives up on
  a silent job after ten — so the app was always killed twenty minutes
  before it could say anything, and every stall looked identical from
  the outside. The guard is now four minutes, comfortably inside that
  window, and it names the file it was working on.
- **Backup and restore are faster over large libraries.** Both asked
  whether the operation had been cancelled once per file — over ten
  thousand round trips in a single restore, each one waiting on the
  other side with no time limit of its own. They now ask a few times a
  second at most, and give up asking rather than waiting forever if no
  answer comes. A cancel is honoured just as promptly.
- **A restore can no longer hang forever on one book.** Restoring
  books drives a hidden browser page, and if one of those writes never
  came back the restore simply waited — at a fraction of a percent of
  CPU, with no error and no end. The guard that looked like it covered
  this was watching the wrong thing and never interrupted anything. Now
  every step has a real limit: a minute and a half for the page to
  load, three minutes for any single write, fifteen for one language.
  A book that will not import is reported and skipped, and the restore
  carries on with the rest instead of stopping dead.
- **Fixed a restore that did all its work and then reported failure.**
  The scratch directory was being cleared before the restored database
  was moved into place — and the database was sitting inside that very
  directory. Everything came across correctly, and then the last step
  went looking for a file that had just been deleted and failed with
  "No such file or directory". Cleanup now runs after the database is
  in place, and a failure to tidy up can no longer fail a restore whose
  data is already home.
- **A restore no longer needs any storage permission.** It is driven by
  白い熊 応用管理 on an app that has never once been opened — 応用管理
  installs it and hands it the data directly — so there is no
  opportunity to grant anything, and the restore now touches nothing
  outside the app's own directories. It also no longer stages its work
  in the cache, which Android is free to clear at any moment: doing so
  cost a restore at 10,050 of 10,325 files on a nearly full phone. The
  backup was staging there too and is moved for the same reason.
- **Progress messages now actually arrive.** Every phase label the app
  sent during a backup or restore was being discarded on receipt,
  because it was travelling under the wrong name — the counts got
  through, the words never did. So the log now says what the app is
  doing, including which file it is on, rather than only how far along
  it is.
- The progress line no longer appears to restart every few seconds
  during a restore. Two parts of the app were reporting at once on
  different scales; the one doing the work now has it to itself.
- **Fixed a restore that failed on a freshly installed phone.** The
  restore staged its extraction in shared storage, which needs the
  "All files access" permission — and a restore driven from 白い熊
  応用管理 runs with no window, so it cannot ask for it. On a phone
  where that permission had never been granted the restore died at the
  very last step, after streaming in 1.26 GB and unpacking the whole
  1.7 GB bundle, with nothing more helpful than "Operation not
  permitted". It now stages inside the app's own storage, which needs
  no permission at all and is markedly faster besides.
- **The app now checks for "All files access" every time it starts** and
  asks for it immediately when it is missing, instead of only at first
  setup. If it is still refused it says so plainly rather than carrying
  on: without it a backup or restore cannot work, and a restore has no
  way to ask for itself.
- The export and import logs now fall back to the app's own storage
  when shared storage cannot be written. Previously the log was lost in
  exactly the situation where it was most needed — the failure above
  produced no log at all, because writing one failed for the same
  reason the restore did.
- **Fixed the actual cause of the failing backup.** The archive writer
  was asked to store one entry without compressing it — the app-data
  bundle, which is already a compressed file — and the routine for that
  does not exist in the compression library this app bundles. The call
  failed with `undefined symbol: zip_set_level`, which killed the
  worker outright. It lay hidden because that path is only taken when a
  backup actually contains app data, which the automation door never
  did until this release. The whole archive is now written without
  compression instead, which is both correct and considerably faster:
  everything large inside it — the bundle, page images, subtitle
  bitmaps, fonts — is already compressed, so deflating it again bought
  a couple of percent for many minutes of work.
- **A backup can no longer hang forever without saying so.** One run
  stopped dead for six and a half hours while writing artifact file
  2264 of 2265 — every thread asleep, no CPU, no error, nothing in the
  log. The cause was in the ZIP library this app vendors: it starts its
  worker without any way of learning that it died, and waits on each
  request with no time limit, so a dead worker means waiting forever.
  It is now told when the worker exits or crashes, and no single step
  may exceed thirty minutes; either way the backup **fails and can be
  retried** instead of sitting there.

  A second round found why the worker was dying at all: it caught only
  one kind of error, so anything else — a file that disappeared between
  being listed and being written, for instance — killed it outright
  instead of being reported. It now survives any error and passes the
  real reason back, and a failure names the entry that caused it. So a
  backup that goes wrong now says which file and why, rather than only
  that something did.
- A cancel from 白い熊 応用管理 is now honoured during the long
  data-export phase as well, not only while the outer archive is being
  written. This matters because once 応用管理 gives up on a job it
  deletes the file underneath us while our handle stays valid — so
  everything written after that point vanishes silently, and stopping
  promptly is the only thing that makes a cancel mean anything.
- Handing the finished archive over no longer blocks the app. It was
  being copied on the main thread, which at 1.7 GB meant nothing else
  in the app could run — including the progress reporting — for the
  whole transfer. It now runs on its own thread and reports the bytes
  as they go.
- **A backup or restore no longer stalls the moment the phone comes off
  the charger.** The app took its wakelock once when the job started and
  never looked at it again — and this phone's power framework
  force-releases it about three minutes in (`Force Released WakeLocks`
  in `dumpsys power`, naming our own tag). Everything after that ran
  unprotected, so on battery the process ended up in uninterruptible I/O
  with its CPU counters frozen, and only moved again when the cable went
  back in. The lock is now re-armed every fifteen seconds by a watchdog
  on its own thread — its own thread specifically because during those
  stalls the main thread is itself blocked, so anything scheduled there
  would have been stuck alongside the work it was meant to protect. The
  log records how many times the lock had to be taken back.
- **The backup is dramatically faster.** It was re-serialising every
  dictionary entry into text: 9,739,165 rows at ~953 bytes each, which
  is 9.3 GB and about 90 minutes for that one table before anything was
  compressed. It now copies the database file itself, which Isar
  documents as the way to back one up and which takes the same time
  whether there are a thousand rows or ten million. Three things
  changed together:
  - The database is copied, not rewritten row by row. The copy also
    carries every collection, including one the old path silently never
    exported at all.
  - Staging moved off shared storage. `/storage/emulated/0` is a FUSE
    filesystem, so every write went through a userspace daemon; from a
    backgrounded app a single 4 MB flush there could stall for minutes,
    which is what produced the long "Waiting for the app" gaps.
  - The row-by-row format, still used as a fallback, is far more
    compact: short field names and empty fields omitted. Bundles written
    before this remain importable.

  While that copy runs, the platform-side byte counter is the only
  thing reporting: the app's own coarse heartbeat is held back for the
  duration, because two counters on different scales made the progress
  appear to restart every few seconds.

  While the database file is being copied the progress line shows the
  bytes written against the expected total. That copy blocks the app's
  own worker outright, so nothing inside it can report — the platform
  side watches the file grow instead, which is why the figure keeps
  moving through a step that used to be a blank minute.

  A file copy only restores onto a matching architecture, Isar version
  and database schema, so the bundle records all three and a restore
  that does not match **refuses outright** rather than half-opening a
  database it cannot read.
- The backup now reports the row counts as it works — dictionaries,
  entries, media items and the rest — instead of a step number that sat
  on `2/6` for the whole database dump. The counters were already being
  formatted into the text; they simply were not being sent as numbers,
  which is what 白い熊 応用管理 builds its progress line from. Phases
  that genuinely cannot report mid-way now repeat their last figure
  every five seconds, so the log no longer falls to "Waiting for the
  app" for half a minute at a time.
- The backup's progress line shows real numbers instead of `0/0`.
  白い熊 応用管理 builds that line from the count and unit, not from the
  text, so the app has to send them; it now reports per-file counts
  while copying dictionary resources, a percentage while compressing
  and extracting, and per-language counts while restoring books,
  falling back to the coarse step number (`2/6`) between them rather
  than to zero.
- The backup's own result line now says whether the library is in the
  archive — `app data included`, or a plain warning that it is not.
  A backup that silently omitted it read exactly like a good one, which
  is what made the previous build's failure invisible until a restore
  came up empty.
- **⚠️ A backup taken through 白い熊 応用管理 now actually contains your
  library, and restores it onto another phone.** Until this build it
  contained neither — dictionaries, books, videos, reading progress and
  the TTU library were absent by construction, and the restore had no
  code to put them back. The archive carried only the six settings
  categories and the three generated-artifact folders, which is why a
  1.10 GB backup could restore to an empty app: the size was the
  scanned-PDF and subtitle-OCR folders, not the library. The door now
  runs the very same cross-device export the in-app Export panel runs,
  and the restore replays it — structured records rewritten through the
  app's own write paths, which is what makes an archive valid on a
  *different* device rather than only the one it came from.
  **Backups taken with any earlier build do not contain your library and
  cannot be made to — take a fresh one.**
  Two notes on the restore: it runs last and replaces dictionaries,
  books, progress and preferences wholesale, so it wins over any
  settings in the same archive; and where a book's audio file cannot be
  found at its old path, those items are left for the in-app remapper
  rather than being dropped.
- **A restore driven from 白い熊 応用管理 now reports its progress.**
  The export side always did; the import side said nothing at all, so a
  1.10 GB archive left the operation log blank for the whole unpack and
  only 応用管理's own five-second heartbeat filled the silence. The
  import now reports each settings category as it lands, then a running
  byte count across the artifact entries, with a five-second ticker
  covering the single long extractions that cannot be subdivided. This
  is not only cosmetic: 応用管理 abandons a transfer that is both silent
  and idle for ten minutes, so until now the restore was surviving on
  its CPU usage alone. A cancel from 応用管理 is also honoured now, at
  entry boundaries.
- The download is about 31 MB larger (216 MB to 248 MB): the OCR
  models and their runtime are carried in the package now, where ML
  Kit's were smaller and partly supplied by Google Play services.

## [1.5.0+025] - 2026-09-04

### Changed

- **⚠️ This build is signed with a real key, so it cannot be installed
  over an older one — you must uninstall first, and that erases the
  app's data.** Every previous release, this project's tagged releases
  included, was signed with the universal Android debug key: the
  release build was configured to fall back to it, and nobody noticed
  for twenty-four builds. Nothing depended on that key being secret so
  there is nothing to undo, but it was not really a signature — anyone
  could have built a package that installed over this app. Releases now
  use a dedicated 4096-bit key held outside the repository. Android
  refuses to update an app when the signature changes, so the switch
  costs one uninstall: **export everything from Settings → UI →
  Export / Import first, uninstall, install this build, then import.**
  Dictionaries, reading positions and Anki settings all live in that
  export. A future release will install over this one normally; it is
  this one crossing that is the problem. A release build with no
  keystore available now fails outright rather than quietly signing
  itself with the debug key again.

## [1.5.0+024] - 2026-09-04

### Changed

- **Automation export is now on by default, and its token is opt-in.**
  The master switch shipped off and every caller had to present a
  48-character secret pasted from this app's settings — which cannot
  survive a wipe, and so was useless for the case the feature now
  exists to serve: restoring this app onto a clean phone where nothing
  has been configured yet. The switch now defaults on, and a new
  「Use authorization token?」 row (default off) decides whether the
  token is asked for at all; the token row is hidden unless it is, so a
  secret is no longer on display under a switch that ignores it. A
  token sent to the app while that switch is off is ignored rather than
  refused, so callers configured against the old behaviour keep
  working. Turning the master switch off still closes the app off
  entirely.

- **Swiping vertically on the reader's right edge now opens the
  subtitle list instead of changing the system volume.** The list
  shows every cue in the loaded `.srt`, opens already scrolled to the
  sentence under the playhead, marks that sentence as it advances,
  and moves playback to any line you tap — the reader's counterpart
  to the video player's transcript, which the same gesture reaches
  there. A `⌖` button in its header scrolls back to what is playing
  after you have browsed away. Tapping a line starts playback from
  it even if the player was paused, matching the transcript. With no
  subtitle file loaded the swipe says so rather than opening an empty
  sheet. The volume swipe is gone; the hardware volume keys are
  unaffected (including volume-key page turning, which is a separate
  setting).

- **Both edge swipes now respond only to drags that are clearly
  vertical, instead of to any drag that wanders 18 pixels off
  horizontal.** Flutter's vertical drag recognizer accepts as soon as
  the distance travelled *along its own axis* passes the touch slop,
  however far the pointer has gone sideways meanwhile — which is fine
  against a competing horizontal scroller and wrong over the reader,
  where a `vertical-rl` Japanese book scrolls horizontally inside a
  webview that takes the drag as a platform view rather than through
  the gesture arena. Nothing contested the edge strips, so a
  horizontal page swipe that drifted slightly off true was claimed as
  a vertical one: the page refused to scroll and the edge gesture
  fired instead. Both strips now judge the direction from the first
  8 pixels of travel and stand down unless the vertical component
  beats the horizontal one by half again — about 34° either side of
  straight up — so an ambiguous diagonal goes to the book.

### Added

- **Sister apps can now back up and restore this app's data through a
  new automation data door.** 応用管理 and 自由作業盤 can ask the app to
  describe itself, write its whole state into a file they opened, and
  put it back — which is what makes restoring onto a wiped phone
  possible. The door is a `ContentProvider` at
  `shiroikuma.jisho.automation` rather than another broadcast, because
  a broadcast cannot tell you who sent it and the caller supplies the
  file the export is written into: callers are checked by exact package
  name, by the uid the kernel reports, and against a pinned signing
  certificate, so a sideloaded app calling itself `shiroikuma.anything`
  is refused. Import lives only here and has deliberately **no**
  broadcast action — the broadcast receiver is exported without a
  permission, and an import there would let any app on the phone
  overwrite this one's data.

- **An export triggered from outside can now be stopped from outside.**
  `shiroikuma.jisho.action.CANCEL_EXPORT` on the existing receiver
  unwinds a running export at the next write boundary, deletes the
  partial file, and answers the original request with
  `ERROR:cancelled`. Previously 中止 in 自由作業盤's panel only stopped
  it *listening*: the app carried on to the end and delivered a backup
  that had been cancelled. Exports are also written under a `.part`
  name and renamed on success, so a cancelled or failed run now leaves
  the backup directory exactly as it found it.

- **The furigana above a dictionary heading has its own size, under
  Settings → UI → Dictionary → Sizes → Furigana.** It previously had
  no size of its own at all: it fell through to the theme's
  `labelSmall` (11sp) no matter how large the heading was set, so a
  28sp heading carried a reading too small to read — the exact
  situation the heading slider exists to prevent. It now defaults to
  14, half the heading default, and rides along with the
  drag-the-left-edge font gesture on the same terms as the entry and
  translation sizes, so a swipe can no longer grow the word away from
  its reading. Stored as `dictionary_heading_ruby_font_size`.

### Fixed

- **Auto-pause playback no longer eats the first moment of the next
  sentence.** Stopping at the end of a subtitle was driven by
  just_audio's position stream, which ticks at most every 200ms on
  anything longer than a few minutes; the player therefore ran past
  the cue end by up to a full tick plus the round trip into
  ExoPlayer, and — since resuming simply played on from wherever it
  had stopped — that overshoot was subtracted from the head of the
  following sentence for good. On TTS audiobooks it was constant:
  renders from shiroikuma-jisho-subtitles leave 0.25s of silence
  between sentences and 0.55s between paragraphs, so roughly two in
  five boundaries were narrower than the overshoot. Auto-pause now
  arms a timer for the cue's end instead of waiting to be told it has
  passed, and — the part that actually guarantees it — snaps the
  playhead back onto that end when it pauses, so whatever was
  overshot is discarded rather than borrowed from the next sentence.
  Every sentence now begins on its first sample. Cue membership is
  half-open (`[start, end)`) so that a playhead parked on a boundary
  counts as being in the gap after it, which is where the old
  poll-driven pause left it: Replay, Prev and Next go on meaning what
  they always did, and resuming cannot re-trigger the pause it has
  just come out of.

- **Tapping a word in the reader no longer raises the white
  selection toolbar over the page.** Highlighting the tapped word
  installs an empty context menu so the app's own selection doesn't
  bring up the floating Search/Stash/Copy/Share/Creator bar, but the
  real menu was restored on the line after the selection script
  returned — which races the WebView's own asynchronous ActionMode
  creation, and lost often enough to be a constant irritation
  (a single tap runs the selection twice, once on the guessed
  highlight length and again on the final one after the lookup
  resolves, so there were two chances to lose it). The restore is now
  deferred past the ActionMode, and back well within the 500ms
  Android itself requires before a deliberate long-press fires, so
  manually selecting text still offers the menu. Fixed in the TTU
  reader, the browser and the mokuro reader, which carried the same
  code.

## [1.5.0+018] - 2026-08-20

### Changed

- **The reader's pull-up sheets — the toolbar's options (`⋮`) and
  navigate-to menus — now draw a yellow line along their top edge.**
  Both are black and slide up over a black reader page, so nothing
  marked where the page ended and the menu began: the rows read as if
  they were part of the text. The line uses the reader's own yellow,
  matching the rest of the sheets' palette. The player's sheets were
  already bounded — `JidoujishoBottomSheet` draws a full yellow border
  around itself in dark mode — so this brings the reader in line with
  them.

## [1.5.0+016] - 2026-08-19

### Fixed

- **Importing a book no longer replaces the one already in the
  library that happens to share its title.** ッツ identifies books by
  title alone: it looked the incoming `dc:title` up, found a match,
  and rewrote *that* record in place — so the new book took over the
  old one's library entry, and, because bookmarks are keyed to the
  record rather than the book, its reading position too. The old book
  was simply gone, with nothing said about it. Two translations of the
  same novel carry the same `dc:title`, which is how this surfaced:
  importing the second one produced a single shelf tile, both halves
  of a split view showing the same text, and a translation book that
  could not be attached to anything because it *was* the primary.

  Imports now insert instead of replacing, and the newcomer's library
  entry is labelled so the two can be told apart — by the language the
  EPUB declares (`Lázár` and `Lázár [cs]`), or by a counter
  (`Lázár (2)`) when it declares none or the tagged name is itself
  taken. A short message names both titles when this happens.

  The EPUB file is never modified: the label exists only as the title
  of ッツ's library entry. This also settles the knock-on problems,
  since per-book state — the translation-book association, split
  ratio, font size, per-book reader settings — is keyed by title and
  so was shared between same-titled books as well. Applies to both
  import buttons and to ッツ's own.

## [1.5.0+015] - 2026-08-17

### Added

- **All books** — a merged shelf at the top of the Reader source
  picker holding every imported book at once: EPUBs from the ッツ
  reader, scanned PDFs and mokuro manga volumes, ordered by what was
  read last, with never-opened books settling after. Each tile is
  badged with the icon of the source it came from, and opens with
  that source. The shelf imports nothing itself — importing stays
  with the individual sources — so its bar carries no add button.
- **All videos** — the same for the Player tab: local video files and
  downloaded YouTube videos in one list, last-played first, each row
  naming its source. Streamed sources (YouTube search, network
  streams) are not on the device and stay in their own tabs.

- **Delete** on the long-press dialog for books held in the ッツ
  library. Clearing only forgot the history row, which did nothing
  for an EPUB — the book stayed in the library and came straight back
  on the shelf. Delete (confirmed first, red, not undoable) removes
  the book from TTU's IndexedDB along with its bookmarks, this app's
  history row, and every per-book setting: attached audio,
  translation-book association, split ratio, per-book reader
  settings. Purging that last group is what makes a re-import of the
  same file come back clean — per-book state is keyed by title, so it
  would otherwise be inherited by the new copy.

- Separate dictionary fonts for **heading**, **entry** and
  **translation**, on the 白い熊 辞書 UI page under a new
  **Dictionary** section, alongside the two sizes. "Entry" is a
  definition written in the target language (a 国語辞典); "translation"
  is a gloss in another one (JMdict and other bilingual
  dictionaries). Which applies is decided per entry from its own
  text, since the import formats record which language a dictionary
  *applies to* but never which language it explains it in. All three
  share the UI page's font list and its "Import font…" action.

### Changed

- The current source is now shown as a **centred pill** — its name and
  icon in bold, ringed by a rounded border in the UI theme's colours —
  instead of grey hint text at the left edge of the bar, which was
  easy to read past. Tapping the pill opens the source picker; the
  source's own open action (file picker, library manager, browser)
  moved onto the leading icon beside it.
- Every source was renamed to say what it reads or plays: **EPUB
  reader (ッツ)**, **PDF reader**, **Manga reader (mokuro)**, **Web
  browser**, **Song lyrics**, **ChatGPT chat**, **Clipboard text**,
  **WebSocket text**; **Local video files**, **Downloaded YouTube**,
  **YouTube search**, **Network stream**. The Reader picker is
  reordered to match: All books, EPUB, PDF, manga, then the rest.
- Each Player source's tab now lists only its own videos. Every one of
  them used to show the entire player history, so switching source
  changed nothing on screen; the merged view is now **All videos**.
- The add button and the Anki card creator swapped places. The app
  bar's second slot now carries the active Reader source's add action
  — Scanned PDF its PDF import, ッツ Ebook Reader its EPUB import,
  mokuro its file picker — so adding a book is one reach from the top
  of the screen and always matches the selected source. The source bar
  below keeps its other actions (tweaks, catalogue, open link, TTU
  settings, manager). Reader sources with nothing to add (browser,
  clipboard, ChatGPT, WebSocket, lyrics) and the Player and Dictionary
  tabs leave the slot empty.
- The Anki card creator button is now **hidden by default**. It moved
  from the app bar to the end of the media source bar; switch it back
  on with "Anki card creator button" under **Toolbars** on the 白い熊
  辞書 UI page (preference key `show_card_creator_button`). The
  creator itself is unchanged and still reachable from dictionary
  results and the quick actions.
- Dev build counters are zero-padded to three digits — `1.5.0+008`
  in the title bar and in the APK filename — so builds sort in order
  in a file manager. Releases are unaffected: still bare `X.Y.Z`.
- **Entry and translation now have separate font sizes**, not just
  separate fonts — three sliders on the UI page (heading, entry,
  translation). An unset translation size follows the entry size, so
  nothing changes until you move it, and the left-edge swipe gesture
  scales all three together, each keeping its proportion.
- The word you tap in a book, a manga page or a web page highlights
  **black on yellow** instead of white on translucent red — the last
  red left inside the reader itself.
- The dictionary popup over a book now has a border, in the same
  colour and corner radius as dialogs (both settable on the UI page),
  so it reads as a panel over the text rather than a hole in it.
- **The accent colour is yellow now, not red.** Red was the shipped
  default and it drove switches, sliders, focus underlines, progress
  spinners, the selected navigation item and the video position bar —
  a splash of red on every black-and-yellow screen. Installs still on
  that default are moved to the theme's yellow once; an accent you
  picked yourself is untouched.
- Toggles are the accent colour throughout: solid when on, the same
  colour at low alpha when off, instead of Material's grey-for-off.
  Slider tracks lost their grey inactive half the same way.
- Media-tile progress bars, the loading bar over an opening source,
  the video position slider, the transcript's selected line, the
  volume and brightness sliders and the subtitle picker's folder
  icons all follow the accent instead of a hardcoded red. Red is kept
  where it carries meaning: destructive actions (delete, clear),
  warnings, the recording indicator, and the toggled-on markers that
  need to stand out *against* yellow.
- Long-pressing the **cog** in the ッツ source bar opens the 白い熊
  辞書 UI page — the same gesture the home page's ⋮ already carried,
  so appearance settings are reachable without leaving the Reader.
- The dictionary settings dialog and the 白い熊 辞書 UI page are both
  **packed tight and set larger** — bigger labels, no inter-line
  padding, switches and radios stripped of their 48px tap-target
  padding, sliders capped so rows sit directly under each other.
- The two font-size fields left the dictionary settings dialog; all
  dictionary typography now lives in one place, on the UI page. The
  dialog carries a **"Fonts and sizes — 白い熊 辞書 UI"** row that opens
  that page scrolled straight to its Dictionary section.
- Dictionary defaults are now **24** for entries and **28** for
  headings (were 16 and 22). Installs still sitting on the old
  defaults are moved up once; a size you set yourself is left alone.

### Fixed

- **The Reader tab no longer waits on the ッツ library.** Opening it
  boots the whole ッツ web app in a hidden webview and has it
  enumerate IndexedDB — 57 MB of assets served by a Dart HTTP server
  on the same isolate that draws the spinner — and until it answered,
  the tab showed nothing. It now paints the last known library
  immediately from a cache and swaps in the fresh listing when the
  scan lands. The same applies to the All books shelf.
- **A stalled scan can no longer hang the tab forever.** The scan
  waited with `while (items == null)` and no timeout, so a single
  dropped request left the spinner turning until the app was killed.
  Every step now has a 25-second deadline, falls back to the cached
  listing, and drops the wedged webview so the next attempt starts
  clean.
- Book covers are written to disk once and skipped on later scans
  (they were re-encoded as base64 blobs on every single scan), and
  one webview per language is now shared by scans and deletes and
  disposed after two minutes idle, instead of one cold-loaded webview
  per operation.
- **Startup could hang on a black screen.** Every cold start
  requested the camera permission — which nothing in the app uses —
  and waited for the system dialog. Dismissed rather than answered,
  that dialog leaves the request unresolved, and it runs before the
  database opens, so the app sat at 0% CPU showing nothing. The
  camera request is gone and the remaining permission requests carry
  a 45-second deadline: missing it costs the permission, not the
  launch.
- Importing an EPUB from the Reader tab could attach the imported
  book as its own **translation book**, opening the split view with
  the same book on both sides. The translation pane adopts whatever
  book it lands on — correct when picking a translation through its
  manager, wrong when an import was routed there. The Reader tab's
  import button now always targets the primary pane (forcing it onto
  the library manager if needed), a book can no longer be registered
  as a translation of itself, and any such association already saved
  is dropped when the book is next opened.

## [1.5.0+6] - 2026-07-25

### Added

- 白い熊 辞書 UI settings page (sister-repo pattern): first item in the
  home menu, and long-press on the menu (⋮) icon opens it directly.
  kxkb-style layout — bold word-width-underlined headings, thin section
  spacers, deep indents, tight rows. Settable live (the running app is
  the preview): background/text/icon/border/accent colours (RGBA-slider
  picker with 8 prior-colour boxes and live hex preview), font — with
  external .ttf/.otf import and each font rendered in its own glyphs —
  weight, global text scale, and dialog/button border width and corner
  radius (sliders, down to 0). Black/yellow is the initialized default.
- Export/Import on the UI page (Kōjiki flow): settable export
  directory (red until set) with latest-export status queried on open;
  category checkboxes incl. generated artifacts (scanned-PDF OCR
  volumes · subtitle-OCR bitmaps · imported fonts, on by default) and
  the cross-device data bundle (off by default); Arcanechat pill row
  (Cancel left, Import · Export right); export success dialog closes
  the whole chain, import offers Later / Restart now.
- 保存復元 automation contract (自由作業盤): token-gated
  `shiroikuma.jisho.action.EXPORT_STATE` / `LIST_CATEGORIES` broadcast
  receivers run the export headlessly (foreground service + background
  Flutter engine) with real-count progress broadcasts and a
  path|bytes|size|categories reply. Automation switch (default off)
  and tap-to-copy token live in the Export/Import section.

### Changed

- Exports always produce ONE zip: `shiroikuma-jisho_<datetime>.zip`
  (no version in the name); a ticked cross-device bundle embeds inside
  it as `app_data.zip` instead of writing a second file. Old export
  names remain importable. The standalone cross-device menu items
  moved from the home menu into the Export/Import panel.
- Checkboxes app-wide: yellow outlined square with yellow checkmark,
  never a filled block.

## [1.5.0] - 2026-07-25

### Added

- Scanned-PDF viewer redesign in the app's black/yellow: black page
  surround, yellow page edge, black toolbar with yellow controls — 50%
  larger by default and adjustable (100–200%) from the mokuro/PDF settings
  dialog. Pages render inverted by default (pure `#FFFF00` ink on black via
  an exact color-matrix filter), toggleable with a ◐ button in the toolbar.
- Tapping scanned text now pops the recognised OCR line out BESIDE the ink
  (left of the column for vertical text, below for horizontal) with the
  tapped character aligned to the finger, and looks it up immediately —
  compare the OCR against the scan at any zoom. Volumes imported from this
  version carry exact per-line geometry; older volumes should be reimported.
- Long-press a revealed OCR line to edit it in place and fix recognition
  errors; corrections are searched immediately and persisted into the
  volume on disk.
- PDF import now runs under a foreground service with a progress
  notification, so it keeps running when the app is backgrounded or the
  screen is off.

### Changed

- Full toolchain migration: Flutter 3.13.5 → 3.44.x, Gradle 7.2 → 9.1.0,
  AGP 7.1.2 → 9.0.1, JDK 11 → 21, compileSdk 34 → 36, and the entire
  dependency graph moved to maintained packages (isar → isar_community,
  flutter_ffmpeg → ffmpeg-kit, upstream flutter_vlc_player 7.4.4 and
  flutter_inappwebview 6.1.5 replacing 2023-era forks, ML Kit un-vendored).
  Mostly invisible by design (Material 3 deliberately opted out to keep the
  e-ink look; targetSdk stays 32), with two user-visible effects:
  - Dictionary search bloom filters now actually persist: the optimisation
    existed but silently never activated because code generation was frozen
    on the old toolchain. Newly imported dictionaries get faster negative
    lookups; existing dictionaries behave as before until reimported.
  - Player upgraded to libVLC 3.6.3.

### Fixed

- PGS subtitles stay visible when pausing mid-cue: the paused-frame bitmap
  overlay (from the OCR bitmap store) now redraws on any pause, not only at
  auto-pause cue boundaries — the new libVLC clears its own subtitle surface
  on every pause, which used to leave the frozen frame bare.

## [1.4.0+25] - 2026-07-24

### Added

- "OCR image subtitles" action in the player's audio/subtitles menu (next to
  "Load subtitles"): converts a Blu-ray PGS subtitle track to real text via
  on-device OCR. Image tracks are detected with ffprobe
  (`hdmv_pgs_subtitle` / `dvd_subtitle`); the chosen track is demuxed with a
  stream copy, decoded by a pure-Dart PGS `.sup` parser (palette/RLE, small
  renders upscaled 2x), each event recognised with the ML Kit Japanese
  engine, and the result written as a `<video-basename>.ocr.srt` sidecar
  next to the video (falling back to the app's `ocrSubtitles/` directory if
  the video's folder is not writable — both locations auto-load on every
  later open). The progress dialog shows ffmpeg extraction percentage, then
  per-event OCR counts; the generated track then behaves like any text
  subtitle: display, tap-to-lookup, and Anki export. VobSub (DVD) tracks
  are detected and listed as not yet supported: a `.idx`/`.sub` SPU parser
  is in the tree, but ffmpeg has no VobSub muxer to extract with — the
  extraction route is future work.
- The player now shows a small top-center status pill while ffmpeg scans a
  newly opened video for embedded subtitles ("Scanning embedded
  subtitles... N%"), so multi-minute passes over large files no longer look
  like a hang. Text-only by design — no spinner — to stay calm on e-ink.
- When OCR'd subtitles are active, the player also renders the original
  bitmap track natively (via VLC's own SPU renderer, enabled only in this
  mode) under the OCR'd tappable text — recognition errors are visible by
  direct comparison. Selecting any other subtitle turns the bitmap overlay
  back off. OCR'd cues end 50 ms before the bitmap's own clear time so
  pause-on-subtitle-end stops while the bitmap is still on screen
  (regenerate an existing `.ocr.srt` via the "OCR image subtitles" menu
  action to pick up the new timing). Image tracks are excluded from the
  per-open embedded-extraction scan — their bitmaps are only unpacked when
  OCR or the comparison overlay needs them, saving a full-file ffmpeg pass
  per image track on every open.
- Bottom-sheet menus restyled: rows are yellow (dark theme) with the active
  option in red plus a trailing red check mark. Previously every row's icon
  was red, drowning the red active highlight.
- In pause-on-subtitle mode with the bitmap comparison overlay active, the
  cue plays to its natural end (speech uncut) and the playhead stays put:
  the just-ended cue's original bitmap is drawn back over the paused frame
  by the app itself, from a per-event bitmap store (PNG per subtitle event
  plus timing index) saved during the OCR pass. No seeking, no playback
  nudging — resume simply continues, replaying nothing. During playback
  VLC still renders the live bitmap track natively. OCR runs from before
  this build have no bitmap store; re-run OCR on the track to create it.
- Local videos now open paused at the persisted resume position, with that
  position's frame displayed: playback is held as soon as VLC reports the
  resume seek applied (position past zero) and a frame decoded. The
  persisted subtitle track loads and is selected while paused; playback
  starts on the user's play press — the first cue no longer renders with
  the wrong (first) track.
- The primary subtitle track selected during playback is now persisted per
  video (like the secondary track always was) and restored on reopen —
  including the OCR'd track, which brings the bitmap comparison overlay
  back with it. "None" is remembered too. Persistence is by stable track
  key, not list position.
- Each image track now gets its own OCR sidecar (`<basename>.ocr-sN-lang
  .srt`), so videos with several PGS tracks (e.g. eng+cze+jpn) track their
  OCR state independently — "✓ OCRed" and the active mark apply per track,
  not globally. Sidecars named with the old `.ocr.srt` scheme keep loading
  as plain external subtitles; re-run OCR to adopt per-track naming.
- Bottom-sheet menus (e.g. "Select subtitle") carry a yellow rounded
  border in the dark theme, matching the dialogs.
- Dialogs ("Exit Media" and all other alert dialogs) restyled in the dark
  theme: yellow rounded border on the panel, and dialog buttons rendered as
  yellow-bordered pills.
- The player status pill now covers the whole loading sequence: it appears
  as "Loading video..." over the black window from the moment the player
  page opens (this phase grows with file size), switches to the ffmpeg
  scanning/extraction percentages, and clears when subtitles are ready.
  Styled yellow-on-black with a yellow rounded border, as is the OCR
  completion flash.
- The "Select subtitle" sheet now integrates the image-subtitle OCR flow:
  a PGS/VobSub track's line reads "(run OCR to use)" and tapping it starts
  the OCR pass directly; once the `.ocr.srt` exists the same line shows a
  green "✓ OCRed" tick and selecting it displays the OCR'd subtitles. The
  dead extraction entries image tracks used to produce, and the redundant
  raw "[.ocr.srt]" external line, no longer appear.

- "Scanned PDF" Reader media source: import an image-only PDF and study it
  as a mokuro-style volume — each page is rasterised on-device (native
  Android `PdfRenderer` over the new `shiroikuma.jisho/pdf` MethodChannel,
  JPEG pages capped at 2000 px wide), OCR'd with the ML Kit Japanese engine,
  and emitted as a legacy-mokuro HTML file that opens in the existing mokuro
  browse page with full tap-to-lookup, sentence mining, and page-image card
  creation. Import shows a "Page X/N" progress dialog; generated volumes
  live under the app documents `scannedPdf/` directory and appear in the
  source's own history. Viewer settings (volume-key paging, dark theme,
  highlight-on-tap, etc.) are shared with the Mokuro source. The mokuro
  0.2.5 legacy HTML runtime (GPL-3, kha-white/mokuro) is vendored under
  `assets/mokuro-template/`.

- On-device Japanese OCR engine (Google ML Kit text recognition v2, bundled
  Japanese model — works offline, ~4 MB APK growth) as the groundwork for
  studying image-based (non-SRT) subtitles such as Blu-ray PGS tracks. The
  `google_mlkit_text_recognition` 0.16.0 / `google_mlkit_commons` 0.12.0
  plugins are vendored under `vendor/` with their SDK/AGP constraints relaxed
  to build on this project's pinned toolchain. A temporary "OCR test (image)"
  entry in the home settings menu picks an image file and shows the raw
  recognition result; it will be replaced by the real subtitle-OCR flow.

## [1.4.0+6] - 2026-07-22

### Fixed

- The player no longer auto-selects a non-functional "Subtitle - Default" entry on videos with more than one embedded subtitle track in the target language (e.g. jiyudoga study mkvs with `aligned` + `asr`). The language-targeted ffmpeg extraction fails on such files after creating a zero-length output, and that empty file used to be treated as a working subtitle; it is now validated and discarded, so the first real embedded track (`aligned`, the Matroska default) is auto-selected and the dead "Default" entry no longer appears.
- Startup and player backgrounds are now pure black with the OS in light mode too: the day-variant Android `LaunchTheme`/`NormalTheme` were based on `Theme.Light` (white window behind the Flutter UI and the video surface) and the Android 12+ day splash was white; all are now black, as is the blank cold-start root behind externally-launched media.

### Changed

- Dark-theme panel surfaces (modal bottom sheets such as the player's track menu, dialogs, popup menus, cards) are now pure black `#000000` instead of dark grey, matching the black/yellow theme and e-ink rendering.

### Notes

- The jiyudoga study-export contract changed (jiyudoga 0.25.1+20): each export is now a single `.mkv` with the study subtitles embedded as Matroska `S_TEXT/UTF8` (SubRip) tracks (`aligned` as default, `asr` alongside when both exist), instead of an mp4 plus `.srt`/`.asr.srt` sidecars. The "YouTube offline" source handles both shapes — the listing scans `.mkv`, embedded tracks are extracted by the player's existing ffmpeg path, and legacy mp4+sidecar exports keep working. Exports made with the short-lived 0.25.1+19 WEBVTT flavour render no text anywhere and should simply be re-exported; the app does not special-case them.

## [1.4.0+3] - 2026-07-22

### Added

- "YouTube offline" Player media source for study videos exported by shiroikuma-jiyudoga's "Study in jisho" button. Listed in the Player source picker between Local Media and YouTube; shows the persisted study folder's videos newest-first with resume positions and thumbnails, hiding entries whose file was deleted. Playback, same-basename SRT sidecar detection (aligned `.srt` defaulting over `.asr.srt`) and thumbnails reuse the Local Media pipeline.
- New Android intent `shiroikuma.jisho.intent.action.STUDY_VIDEO` (extras: `path`, `subtitlePath`, `studyDir`, `title`, `videoId`, `source`): persists the study folder, imports the video into the "YouTube offline" source and opens the player immediately. Works on both cold start and warm delivery; also fireable from adb for testing. The contract is shared with jiyudoga — changes must land in both repos together.

### Changed

- App launcher label changed from `白い熊の辞書` to `白い熊 辞書` (Android and iOS).

## [1.4.0+2] - 2026-07-16

### Fixed

- The Reader tab no longer gets stuck in a "Local server port already in use / Retrying in 3 seconds…" loop after exiting and re-opening the app. When the Android process outlives the UI (audio service, dictionary indexing in progress), the old run's TTU asset server still held its fixed port and the relaunched app could never bind it. The server now binds with `shared: true` (`SO_REUSEPORT`), so a relaunch binds alongside any stale holder instead of retrying forever.

### Changed

- The Android `versionName` now carries the full pubspec version verbatim — `X.Y.Z+N` on dev builds, bare `X.Y.Z` on releases — so installers and the in-app version line can tell dev builds apart. Previously Flutter stripped the `+N` and every dev build presented itself as the same `X.Y.Z`.
- Built APKs are named with the `shiroikuma-jisho_` prefix (previously `shiroikumanojisho_`), aligning with the other shiroikuma-* apps.

## [1.4.0] - 2026-06-13

### Added

- Toggle for the left-edge font-size swipe gesture in dictionary results, in the dictionary settings dialog ("Left-edge font-size swipe gesture"). Lets the gesture added in 1.0.4 be turned off on devices where it interferes with scrolling or is triggered accidentally. Persisted under the `dictionary_font_size_swipe_enabled` preference; defaults to on, preserving existing behaviour.

### Fixed

- The card-creator buttons on a dictionary lookup no longer crash when a result references a dictionary that has since been deleted. Entries with a dangling dictionary reference are now skipped instead of dereferenced, and a lookup that yields no usable meanings leaves the field empty rather than throwing.
- Frequency information in dictionary results no longer renders a grey screen. Two causes were fixed: a Yomichan definition whose CSS omits `list-style-type` now falls back to the `square` list style instead of throwing, and frequencies referencing a deleted dictionary are skipped.
- The app no longer requests the `READ_PHONE_STATE` permission. It was pulled in transitively by a dependency and tripped Google Play Protect on install; it is now stripped at manifest-merge time with `tools:node="remove"`.

## [1.3.1] - 2026-05-20

UI-fit fixes for narrow screens.

### Added

- Customisable reader audio toolbar: per-button visibility setting persisted under the `reader_audio_toolbar_hidden_items` preference. Eight buttons are hideable (seek previous/next, replay, time display, previous/next chapter, translation-book toggle, navigate menu); play/pause, the position slider, and the options menu are always shown.
- "Customise reader toolbar" entry in the home settings menu, alongside "Reader audio toolbar height". The same dialog is also reachable from the toolbar's own options (⋮) menu — having both is deliberate, since the toolbar entry point itself can be clipped off-screen on narrow devices, making it unreachable.

### Fixed

- Long labels in the home settings menu ("Reader audio toolbar height", "Import data (cross-device)", "View repository on GitHub") clipping off the right edge of the screen instead of wrapping. Each menu item's text is now `Flexible` with `softWrap: true`.

## [1.3.0] - 2026-05-12

### Added

- Seven Android broadcast intents for external control of the reader audio toolbar, in the `shiroikuma.jisho.action.PLAYBACK_*` namespace:
  - `PLAYBACK_NEXT_SUBTITLE`, `PLAYBACK_PREVIOUS_SUBTITLE`, `PLAYBACK_REPLAY_SUBTITLE` — subtitle navigation.
  - `PLAYBACK_TOGGLE_PLAY_PAUSE` — toggle play/pause.
  - `PLAYBACK_PREVIOUS_CHAPTER`, `PLAYBACK_NEXT_CHAPTER` — chapter navigation.
  - `PLAYBACK_CYCLE_MODE` — cycle normal → condensed → auto-pause → normal, used to switch in and out of shadowing mode without opening the toolbar menu.
- Tasker (and any other broadcast-capable automation tool) can drive these via Send Intent: action set to one of the strings above, package set to `shiroikuma.jisho`, target set to Broadcast Receiver, no extras required.

### Notes

- Intents only take effect when the app is running and a reader page with audio is open. Intents fired against a closed app or a non-reader page are silently dropped; the app deliberately does not cold-start playback from a broadcast.

## [1.2.0] - 2026-05-06

Major release: full cross-device data portability.

### Added

- Cross-device export and import as a complement to the existing on-device backup and restore. Where backup and restore produce bit-for-bit snapshots only meaningful on the same device, export and import serialise everything as portable JSONL plus a manifest so a bundle can move between devices and survive package re-signing.
- The bundle covers all Isar collections (dictionaries, dictionary entries, tags, frequencies, pitches, anki mappings, media items, search history, browser bookmarks, mokuro catalogs), every Hive preferences box (`appModel`, `readerAudio`, per-source boxes), the `dictionaryResources/` directory, and per-language TTU IndexedDB contents.
- Bundles are ZIP files written to `/storage/emulated/0/tmp/`. On import the chosen bundle is extracted, live data is replaced, and the app exits to force a clean reload.
- Audio path remap on import: when imported audio paths do not resolve on the destination device, the user can supply a new base directory and a suffix matcher rebinds files automatically without a full re-import.

### Fixed

- **TTU language lookup on import was silently skipping every language.** The code looked up `appModel.languages[code]` where `code` was bare (`"ja"`) but the map was keyed on locale tags (`"ja-JP"`). Books were never restored. Now matches by `languageCode` directly.
- **Theme reverted from dark to light after import.** The `is_dark_mode` Hive key was missing from bundles whenever the user had not explicitly toggled the theme, and a Flutter cold-start `platformBrightness` quirk would then return Light briefly and lock in the wrong theme. Exports now force-persist the effective value to the bundle.
- Hive boxes are explicitly flushed and `Hive.close()` is called before `exit(0)` on the import side, so the OS does not lose pending writes during the post-import restart.
- Backup and restore inherited matching improvements: progress dialog, async cleanup, and tolerance for files vanishing mid-snapshot (Chromium IndexedDB blob garbage collection used to race against the copy and fail the whole backup with `PathNotFoundException`).

### Changed

- Isar import uses `writeTxnSync` + `putAllSync` for bulk writes. Significantly faster than the async pair on Android flash, with batch sizes small enough to keep the UI responsive.
- Staging and extract directory cleanup is asynchronous with progress reporting; the previous synchronous `deleteSync` blocked the UI thread for tens of seconds on slow flash (Boox-class e-readers).

## [1.1.0] - 2026-05-04

Baseline minor release. No functional changes from 1.0.4 — version bump only, establishing a clean `1.1.0` baseline before the export/import work that would land in 1.2.0.

## [1.0.4] - 2026-04-24

### Added

- Dictionary font-size adjustment via swipe along the left edge of the entry view, with a real-time overlay showing the current size. Existing centred overlays unified so all dictionary HUDs share the same anchor.

## [1.0.3] - 2026-04-24

### Added

- Per-book, per-pane font size in the TTU reader, replacing the previous shared-origin behaviour where every book inherited the same font size.

### Fixed

- TTU writing mode now forced per-WebView to match each book's body CSS, fixing books that displayed in the wrong orientation when reopened.
- Appearance CSS no longer applied on TTU non-book pages (library, settings), where it caused visual glitches.

### Changed

- Home title bar decodes the pubspec `+N` build counter directly from the packed `versionCode` so dev builds are unambiguously identifiable.

## [1.0.2] - 2026-04-24

### Added

- Every Japanese word in a dictionary entry is tappable for recursive lookup. Previously only the headword was tappable.
- Scan-words behaviour (auto-detection of word boundaries on tap) extended to all supported languages, not just Japanese.
- Back and Close-all buttons on the recursive entry AppBar so deep dictionary chains can be exited cleanly.

### Fixed

- Per-book reader state collision across languages: opening a book in one language no longer clobbered the saved position of a same-titled book in another.

## [1.0.1] - 2026-04-24

### Added

- Per-book writing mode in the TTU reader, with Japanese books defaulting to vertical writing.
- Primary/Secondary font override that takes precedence over TTU's default font rules.
- `tools/bump-build.sh` helper for advancing the pubspec `+N` counter on dev builds.

### Changed

- Dictionary search UI replaced the heavy FloatingSearchBar with a simple AppBar plus a search dialog; faster to open, easier to dismiss.
- Per-book reader state is keyed by the TTU SPA book id rather than the surrounding widget item, so state survives navigation churn within TTU.
- TTU paragraph spacing uses logical `margin-block-end` so vertical-writing books fill their columns correctly without horizontal gap artifacts.
- Audio toolbar's filename overlay is smaller and indicates `/srt` (subtitle file presence) in the title; dev builds also show the `+N` build counter in the title.

## [1.0.0] - 2026-04-23

Initial release after the rename and restructure from `ShiroiKuma0/jidoujisho2`.

### Changed

- The repo was flattened: the Flutter project root is now the repo root, no more `yuuna/` subdirectory.
- Dart package renamed `yuuna` → `shiroikumanojisho`.
- Android `applicationId` and Java package renamed to `shiroikuma.jisho`.
- App display name set to `白い熊の辞書` (Android and iOS); iOS identity also updated.
- Version baseline reset to `1.0.0+1` post-rename.

[Unreleased]: https://github.com/ShiroiKuma0/shiroikuma-jisho/compare/1.5.0+025...HEAD
[1.5.0+025]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.5.0+025
[1.5.0+024]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.5.0+024
[1.4.0+25]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.4.0+25
[1.4.0+6]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.4.0+6
[1.4.0+3]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.4.0+3
[1.4.0+2]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.4.0+2
[1.4.0]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.4.0
[1.3.1]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.3.1
[1.3.0]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.3.0
[1.2.0]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.2.0
[1.1.0]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.1.0
[1.0.4]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.0.4
[1.0.3]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.0.3
[1.0.2]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.0.2
[1.0.1]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.0.1
[1.0.0]: https://github.com/ShiroiKuma0/shiroikuma-jisho/releases/tag/1.0.0
