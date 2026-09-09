import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async_zip/async_zip.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:shiroikumanojisho/src/utils/ui_settings/ui_settings_export.dart';

/// Thrown out of [StateExport.run] when a cancel was noticed at a write
/// boundary. Carried as an exception rather than a return value so the
/// `finally` that deletes the `.part` is the same one every other
/// failure goes through — a cancelled export must leave the backup
/// directory exactly as it found it.
class StateExportCancelled implements Exception {
  /// Construct the marker.
  const StateExportCancelled();

  @override
  String toString() => 'cancelled';
}

/// One exportable category of the 保存復元 state-export contract.
class StateCategory {
  /// Define a category.
  const StateCategory(this.id, this.label, {this.parentId});

  /// Stable id — the ZIP entry name and the `items` token.
  final String id;

  /// Display label for pickers (ours and 自由作業盤's).
  final String label;

  /// Parent id for sub-options, null for top-level.
  final String? parentId;
}

/// The single-ZIP state export/import core — the one implementation
/// behind both the Export/Import panel and the headless 保存復元
/// automation receiver (the contract forbids duplicating export logic).
///
/// ZIP layout (family pattern): `manifest.json` +
/// one `<id>.json` per settings category (plain key→value maps) +
/// `artifacts/<dir>/...` file entries for the artifact sub-options.
class StateExport {
  /// Format tag in the manifest.
  static const String format = 'shiroikuma-jisho-state';

  /// Export filename prefix: the export is ALWAYS one ZIP named
  /// `shiroikuma-jisho_<yyyy-MM-dd_HH-mm-ss>.zip` (no version).
  static const String filePrefix = 'shiroikuma-jisho_';

  /// Entry name of an embedded cross-device bundle — the *semantic*
  /// export produced by [AppExportImport], written by the in-app
  /// Export panel. Restoring it needs a live `AppModel` and a headless
  /// WebView, so only the in-app Import can consume it.
  static const String bundleEntry = 'app_data.zip';

  /// Category id for the app's own data — dictionaries, books,
  /// reading progress, TTU library. Always carried as [bundleEntry];
  /// the in-app panel and the automation door write the same format.
  static const String appDataId = 'app_data';

  /// Manifest schema version.
  static const int version = 1;

  /// Artifact sub-option id → app-documents directories.
  ///
  /// `artifacts.fonts` carries TWO directories, because the app has two
  /// independent font stores fed by two different import buttons:
  ///
  ///   fonts/       imported from the 白い熊 辞書 UI page, registered with
  ///                the engine by FontLoader, used for the app's own UI
  ///   user_fonts/  imported from the reader's settings dialog, served
  ///                over the loopback HTTP server and injected into the
  ///                book as @font-face (see [UserFontsStore])
  ///
  /// Only the first was ever exported. The *choice* of reader font is a
  /// preference and so rides along in Hive, which made the omission
  /// look like something stranger than it was: a restored app named
  /// "Source Han Serif JP" in the reader settings and then rendered the
  /// book in the default face, with nothing to say why (白い熊,
  /// 2026-09-09).
  ///
  /// Deliberately folded into the existing sub-option rather than given
  /// a new id. A new id would be absent from every selection 応用管理
  /// has already stored, so reader fonts would have gone on being
  /// silently dropped until someone noticed and ticked a new box —
  /// which is the same failure, one indirection further away.
  static const Map<String, List<String>> artifactDirs = {
    'artifacts.pdf': ['scannedPdf'],
    'artifacts.ocr': ['ocrSubtitles'],
    'artifacts.fonts': ['fonts', 'user_fonts'],
  };

  /// The category table: six settings categories (ids matching the
  /// ZIP entry names), then the artifacts parent with three
  /// independently-selectable children.
  static const List<StateCategory> categories = [
    StateCategory('ui_theme', 'UI theme (colours · fonts · shapes)'),
    StateCategory('player', 'Player & subtitles'),
    StateCategory('reader', 'Reader & audio toolbar'),
    StateCategory('dictionary', 'Dictionary & search'),
    StateCategory('creator', 'Creator & Anki'),
    StateCategory('other', 'Other settings'),
    StateCategory('artifacts', 'Generated artifacts'),
    StateCategory('artifacts.pdf', 'Scanned-PDF OCR volumes',
        parentId: 'artifacts'),
    StateCategory('artifacts.ocr', 'Subtitle OCR bitmaps',
        parentId: 'artifacts'),
    StateCategory('artifacts.fonts', 'Imported fonts',
        parentId: 'artifacts'),
    StateCategory(appDataId,
        'App data (dictionaries · books · reading progress)'),
  ];

  /// Ids of the settings categories, in [UiSettingsExport.categories]
  /// order (the two tables are index-aligned).
  static List<String> get settingsIds => [
        for (final category in categories)
          if (category.parentId == null &&
              category.id != 'artifacts' &&
              category.id != appDataId)
            category.id,
      ];

  /// Every id that carries data (the artifacts parent has no own
  /// data — per the contract, the parent id alone means "own data
  /// only", which for us is empty).
  static Set<String> get allIds => {
        ...settingsIds,
        ...artifactDirs.keys,
        appDataId,
      };

  /// The `id<TAB>label[<TAB>parent]` listing for LIST_CATEGORIES.
  static String categoriesListing() => categories
      .map((category) => category.parentId == null
          ? '${category.id}\t${category.label}'
          : '${category.id}\t${category.label}\t${category.parentId}')
      .join('\n');

  /// Validate an `items` CSV; returns the unknown tokens (empty = ok).
  static List<String> unknownItems(String items) => items
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .where((item) =>
          !allIds.contains(item) && item != 'artifacts')
      .toList();

  /// Resolve an `items` CSV to concrete data-carrying ids.
  /// Absent/empty = everything.
  static Set<String> resolveItems(String? items) {
    if (items == null || items.trim().isEmpty) {
      return allIds;
    }
    final tokens = items
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
    // The artifacts parent alone contributes no data of its own.
    tokens.remove('artifacts');
    return tokens;
  }

  /// Run the export: write one ZIP into [directory] and return it.
  /// [onProgress] receives (text, current, total, unit) with real
  /// counts, already throttle-friendly (call sites throttle).
  static Future<File> run({
    required Box box,
    required Set<String> ids,
    required String directory,
    required String appVersion,
    File? embedBundle,
    void Function(String text, int current, int total, String unit)?
        onProgress,
    Future<bool> Function()? shouldCancel,
  }) async {
    // Same bounded, throttled cancel check the import uses: one
    // platform-channel round trip per file is thousands of unbounded
    // awaits, and a cancel is honoured at a file boundary either way.
    var lastCancelCheck = DateTime.fromMillisecondsSinceEpoch(0);
    var lastCancelResult = false;
    Future<bool> cancelled() async {
      if (shouldCancel == null) {
        return false;
      }
      final now = DateTime.now();
      if (now.difference(lastCancelCheck) < const Duration(seconds: 2)) {
        return lastCancelResult;
      }
      lastCancelCheck = now;
      lastCancelResult = await shouldCancel()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
      return lastCancelResult;
    }

    Directory(directory).createSync(recursive: true);
    final timestamp =
        DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final zipTarget =
        File(path.join(directory, '$filePrefix$timestamp.zip'));
    // Written under `.part` and renamed on success. A cancelled or
    // failed run therefore never leaves a short archive behind for a
    // later restore to find — 保存復元 §1, obligation 2.
    final partTarget = File('${zipTarget.path}.part');

    final selectedSettings =
        settingsIds.where(ids.contains).toList();
    final selectedArtifactDirs = [
      for (final entry in artifactDirs.entries)
        if (ids.contains(entry.key)) entry,
    ];

    // Enumerate artifact files up front for a real total.
    final appDocDir = await getApplicationDocumentsDirectory();
    final artifactFiles = <MapEntry<String, File>>[];
    for (final entry in selectedArtifactDirs) {
      for (final dirName in entry.value) {
        final dir = Directory(path.join(appDocDir.path, dirName));
        if (!dir.existsSync()) {
          continue;
        }
        for (final file in dir.listSync(recursive: true).whereType<File>()) {
          final relative =
              path.relative(file.path, from: appDocDir.path);
          artifactFiles.add(MapEntry('artifacts/$relative', file));
        }
      }
    }

    final writer = ZipFileWriter();
    var completed = false;
    try {
      // Level 1, and the 1 matters more than it looks.
      //
      // Level 0 stores entries, and this writer sets the
      // data-descriptor flag on every entry it writes. STORED plus a
      // data descriptor is an invalid combination — a descriptor
      // exists for when the size is not known in advance, which cannot
      // be true of a stored entry — and Java's zip readers refuse it:
      // ZipInputStream with "only DEFLATED entries can have EXT
      // descriptor", Android's ZipFile with "invalid CEN header (bad
      // signature)". Verified against the real 2,947,112,833-byte
      // archive on 2026-09-09: all 2,273 entries were STORED with the
      // descriptor bit set, and the restore could not open it.
      //
      // Level 1 makes them DEFLATE, which is legal with a descriptor
      // and readable by everything. It is also nearly free: the bulk
      // of this archive is already-compressed data, and level 1 passes
      // that through at a rate a phone will not notice — unlike the
      // level 6 default, which spent fifteen minutes for a couple of
      // percent.
      await writer.create(partTarget, compressionLevel: 1);

      // Manifest + settings categories.
      final byLabel = UiSettingsExport.categorise(box);
      final labels = UiSettingsExport.categories;
      final manifest = {
        'format': format,
        'version': version,
        'app': 'shiroikuma.jisho',
        'appVersion': appVersion,
        'createdTs': DateTime.now().toIso8601String(),
        'categories': [
          ...selectedSettings,
          for (final e in selectedArtifactDirs) e.key,
          if (embedBundle != null) appDataId,
        ],
      };
      await writer.writeData('manifest.json',
          Uint8List.fromList(utf8.encode(jsonEncode(manifest))));

      for (var i = 0; i < selectedSettings.length; i++) {
        if (await cancelled()) {
          throw const StateExportCancelled();
        }
        final id = selectedSettings[i];
        final labelIndex = settingsIds.indexOf(id);
        final data = byLabel[labels[labelIndex].key] ?? {};
        onProgress?.call('区分 ${i + 1}/${selectedSettings.length} — $id',
            i + 1, selectedSettings.length, '区分');
        await writer.writeData('$id.json',
            Uint8List.fromList(utf8.encode(jsonEncode(data))));
      }

      // Artifact files with real counts.
      for (var i = 0; i < artifactFiles.length; i++) {
        if (await cancelled()) {
          throw const StateExportCancelled();
        }
        // The name goes in the text as well as the count: when this
        // hung at "ファイル 2264/2265" the one thing the notification
        // could not tell us was WHICH file the zip worker died on.
        onProgress?.call(
            'ファイル ${i + 1}/${artifactFiles.length} — '
            '${path.basename(artifactFiles[i].value.path)}',
            i + 1,
            artifactFiles.length,
            'ファイル');
        try {
          await writer.writeFile(
              artifactFiles[i].key, artifactFiles[i].value);
        } catch (e) {
          // The entry name goes into the thrown message because that is
          // what reaches 応用管理's terminal reply — it renders the
          // counts and the final error, never our progress text. Without
          // this a failure says only that the zip worker died.
          throw StateError('artifact ${artifactFiles[i].key}: $e');
        }
      }

      // Embedded cross-device bundle: stored uncompressed — it is
      // already a DEFLATE zip; recompressing would double the time
      // for zero gain.
      if (embedBundle != null) {
        if (await cancelled()) {
          throw const StateExportCancelled();
        }
        final size = embedBundle.lengthSync();
        onProgress?.call('連携データ ${byteCount(size)}', size, size,
            'bytes');
        try {
          // No `compress: false` here any more — the archive is already
          // at level 0, so the entry is stored either way, and the
          // per-entry path is the one that was fatal.
          await writer.writeFile(bundleEntry, embedBundle);
        } catch (e) {
          throw StateError('$bundleEntry (${byteCount(size)} bytes): $e');
        }
      }
      completed = true;
    } finally {
      await writer.close();
      if (completed) {
        partTarget.renameSync(zipTarget.path);
      } else if (partTarget.existsSync()) {
        // Cancel and failure land here alike: nothing partial survives.
        partTarget.deleteSync();
      }
    }
    return zipTarget;
  }

  /// How often a long step re-announces itself while nothing is
  /// changing. Matched to 白い熊 応用管理's own five-second tick so its
  /// "Waiting for the app" filler never gets a gap to appear in — and
  /// the text carries elapsed time, so a repeat still says something
  /// rather than being noise.
  static const Duration importHeartbeat = Duration(seconds: 5);

  /// Import selected [ids] from a state ZIP: settings merge per key
  /// (never clear), artifact entries overwrite same-named files.
  /// Returns id → restored count (keys or files).
  ///
  /// Extraction is a SINGLE native pass over the archive, filtered by
  /// [ZipFileOperation.skipItem]. It used to be one call per entry
  /// through async_zip's worker isolate — 10,325 of them in a real
  /// restore — and that is where every restore failure of 2026-09-09
  /// happened: a crash on a missing symbol, a wedge on a 4 GB entry,
  /// and a wedge on the 1.7 GB bundle, each leaving the process idle
  /// with nothing to say. The native extractor has never failed at any
  /// size, reports its own progress, and needs no round trip per file.
  ///
  /// [onProgress] receives (text, current, total, unit), the same shape
  /// [run] uses, and [shouldCancel] is polled at entry boundaries.
  static Future<Map<String, int>> import({
    required Box box,
    required File archive,
    required Set<String> ids,
    void Function(String text, int current, int total, String unit)?
        onProgress,
    Future<bool> Function()? shouldCancel,
    Future<void> Function(File bundle)? onAppData,
  }) async {
    final summary = <String, int>{};
    final appDocDir = await getApplicationDocumentsDirectory();
    final started = DateTime.now();

    String elapsed() {
      final d = DateTime.now().difference(started);
      final m = d.inMinutes;
      final sec = d.inSeconds - m * 60;
      return m > 0 ? '$m分$sec秒' : '$sec秒';
    }

    var lastText = '展開の準備';
    var lastCurrent = 0;
    var lastTotal = 100;
    var lastUnit = '%';
    var lastSentAt = DateTime.fromMillisecondsSinceEpoch(0);

    void report(String text, int current, int total, String unit,
        {bool force = false}) {
      lastText = text;
      lastCurrent = current;
      lastTotal = total;
      lastUnit = unit;
      final now = DateTime.now();
      // The native extractor calls back per entry — thousands of times.
      // Forwarding every one would be channel spam for no extra
      // information; twice a second is already smoother than the log
      // can render.
      if (!force && now.difference(lastSentAt).inMilliseconds < 500) {
        return;
      }
      lastSentAt = now;
      onProgress?.call(text, current, total, unit);
    }

    Timer? heartbeat;
    if (onProgress != null) {
      heartbeat = Timer.periodic(importHeartbeat, (_) {
        if (DateTime.now().difference(lastSentAt) < importHeartbeat) {
          return;
        }
        lastSentAt = DateTime.now();
        onProgress('$lastText · 経過 ${elapsed()}',
            lastCurrent, lastTotal, lastUnit);
      });
    }

    // Staging is app-private and NOT the cache: a restore runs on an
    // app that has never been opened, so it holds no permissions, and
    // Android trims cache directories under storage pressure.
    final staging = Directory(path.join(appDocDir.path,
        'restoreStaging_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(started)}'));

    try {
      if (staging.existsSync()) {
        staging.deleteSync(recursive: true);
      }
      staging.createSync(recursive: true);

      final wantedSettings =
          settingsIds.where(ids.contains).map((id) => '$id.json').toSet();
      final wantedArtifactPrefixes = [
        for (final entry in artifactDirs.entries)
          if (ids.contains(entry.key))
            for (final dirName in entry.value) 'artifacts/$dirName/',
      ];
      final wantsAppData = onAppData != null && ids.contains(appDataId);

      bool wanted(String name) {
        if (name == 'manifest.json') return true;
        if (wantedSettings.contains(name)) return true;
        if (wantsAppData && name == bundleEntry) return true;
        return wantedArtifactPrefixes.any(name.startsWith);
      }

      // Accumulated bytes rather than the extractor's percentage: a
      // percentage rounds to the same digit for minutes on a
      // multi-gigabyte entry, and then cannot be told from a stall.
      final archiveBytes = archive.lengthSync();
      var extracted = 0;
      report('展開 0/${byteCount(archiveBytes)}', 0, archiveBytes, 'bytes',
          force: true);
      await ZipFile.extractToDirectory(
        zipFile: archive,
        destinationDir: staging,
        onExtracting: (entry, progress) {
          if (entry.isDirectory) {
            return ZipFileOperation.includeItem;
          }
          if (!wanted(entry.name)) {
            return ZipFileOperation.skipItem;
          }
          extracted += entry.uncompressedSize ?? 0;
          report(
              '展開 ${byteCount(extracted)}/${byteCount(archiveBytes)} — '
              '${path.basename(entry.name)}',
              extracted,
              archiveBytes,
              'bytes');
          return ZipFileOperation.includeItem;
        },
      );
      report('展開 ${byteCount(extracted)}/${byteCount(archiveBytes)}',
          extracted, archiveBytes, 'bytes', force: true);

      if (!File(path.join(staging.path, 'manifest.json')).existsSync()) {
        throw const FormatException(
            'No 白い熊 辞書 state export found in that file.');
      }

      // ---- settings ----
      final selectedSettings = settingsIds
          .where(ids.contains)
          .where((id) =>
              File(path.join(staging.path, '$id.json')).existsSync())
          .toList();
      for (var i = 0; i < selectedSettings.length; i++) {
        if (await shouldCancel?.call() ?? false) {
          throw const StateExportCancelled();
        }
        final id = selectedSettings[i];
        report('区分 ${i + 1}/${selectedSettings.length} — $id',
            i + 1, selectedSettings.length, '区分', force: true);
        final data = jsonDecode(
                File(path.join(staging.path, '$id.json')).readAsStringSync())
            as Map<String, dynamic>;
        var count = 0;
        for (final entry in data.entries) {
          box.put(entry.key, entry.value);
          count++;
        }
        summary[id] = count;
      }

      // ---- artifacts ----
      // Already extracted; moving a whole directory is one rename on
      // the same filesystem, where the old path copied every file
      // individually out of the archive.
      for (final artifactEntry in artifactDirs.entries
          .where((entry) => ids.contains(entry.key))) {
        // The sub-option's count is the sum over its directories --
        // `artifacts.fonts` restores both font stores, and reporting
        // them separately would make one selected box look like two.
        summary[artifactEntry.key] = 0;
        for (final dirName in artifactEntry.value) {
          final src =
              Directory(path.join(staging.path, 'artifacts', dirName));
          if (!src.existsSync()) {
            continue;
          }
          final dst = Directory(path.join(appDocDir.path, dirName));
          report('配置 $dirName', 0, 1, '区分', force: true);
          final moved =
              src.listSync(recursive: true).whereType<File>().length;
          if (dst.existsSync()) {
            dst.deleteSync(recursive: true);
          }
          dst.parent.createSync(recursive: true);
          try {
            src.renameSync(dst.path);
          } on FileSystemException {
            await _copyDirectory(src, dst);
            src.deleteSync(recursive: true);
          }
          summary[artifactEntry.key] =
              (summary[artifactEntry.key] ?? 0) + moved;
          report('配置 $dirName — $moved ファイル', 1, 1, '区分', force: true);
        }
      }

      // ---- the cross-device bundle, last ----
      // It replaces dictionaries, books, progress and preferences
      // wholesale, so anything applied above would only be overwritten.
      final bundle = File(path.join(staging.path, bundleEntry));
      if (wantsAppData && bundle.existsSync()) {
        final bundleBytes = bundle.lengthSync();
        report('アプリデータ ${byteCount(bundleBytes)}',
            bundleBytes, bundleBytes, 'bytes', force: true);
        // The nested import reports for itself, on its own scales; two
        // emitters alternating made the count appear to restart.
        heartbeat?.cancel();
        heartbeat = null;
        await onAppData(bundle);
        summary[appDataId] = 1;
      }
    } finally {
      heartbeat?.cancel();
      // Scratch only — the data is in place by now, so a failure to
      // tidy up must never fail the restore.
      try {
        if (staging.existsSync()) {
          staging.deleteSync(recursive: true);
        }
      } catch (_) {}
    }
    return summary;
  }

  /// Recursive copy, used only when staging and the destination turn
  /// out to be on different filesystems and a rename is impossible.
  static Future<void> _copyDirectory(Directory src, Directory dst) async {
    dst.createSync(recursive: true);
    for (final entity in src.listSync(recursive: true)) {
      final rel = path.relative(entity.path, from: src.path);
      if (entity is Directory) {
        Directory(path.join(dst.path, rel)).createSync(recursive: true);
      } else if (entity is File) {
        final target = File(path.join(dst.path, rel));
        target.parent.createSync(recursive: true);
        entity.copySync(target.path);
      }
    }
  }

  /// Full byte count with thousands separators — `1,685,691,651`.
  ///
  /// Progress lines use this rather than a rounded size: "1.57 GB"
  /// looks identical for minutes at a time, so it cannot be told apart
  /// from a stall, whereas a digit changing anywhere in the number
  /// proves the thing is alive.
  static String byteCount(int bytes) =>
      NumberFormat.decimalPattern().format(bytes);

  /// Human size for the reply (`4.6 MB`, `1.20 GB`).
  static String humanSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }
}
