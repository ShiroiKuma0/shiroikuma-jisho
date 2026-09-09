// Proof that the cross-device backup carries the Hive boxes it must.
//
// Written 2026-09-09 after TWO boxes turned out to have been absent from
// every backup this app had ever produced:
//
//   user_fonts  the imported-font index. Its font FILES travelled as an
//               artifact directory, so the font was physically present
//               on the restored device while the index that maps the CSS
//               family name to the file was not. The reader therefore
//               injected no @font-face and the book rendered in the
//               default face, even though its setting still named the
//               font. Indistinguishable, from the outside, from the font
//               not having been restored at all.
//   ttuLibrary  the library listing the Reader tab paints from before a
//               WebView exists.
//
// Both were found by inspecting a real backup, not by reading the code —
// the code had been read several times. Hence this test: it exercises
// the actual dump and restore functions against a real Hive box, so a
// box dropped from the export fails here instead of on a phone.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shiroikumanojisho/src/media/sources/reader_ttu_source.dart';
import 'package:shiroikumanojisho/src/utils/misc/app_export_import.dart';
import 'package:shiroikumanojisho/src/utils/user_fonts_store.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('jisho_hive_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('the export names every box the app persists user data in', () {
    expect(AppExportImport.builtinHiveBoxes, contains(UserFontsStore.boxName));
  });

  test('the bundle copies every directory nothing else can rebuild', () {
    // ttuCovers holds one cover image per book per language. It was
    // missed in the first pass of the audit because it is built by
    // string interpolation rather than path.join(dir, 'name') — the same
    // blind spot that hid user_fonts.
    expect(AppExportImport.bundleCopyDirs, contains('ttuCovers'));
    expect(AppExportImport.bundleCopyDirs, contains('user_fonts'));
    expect(AppExportImport.bundleCopyDirs, contains('fonts'));
    expect(AppExportImport.bundleCopyDirs, contains('thumbnails'));
  });

  test('the derived library cache is NOT exported', () {
    // Regression guard, not a style preference. ttuLibrary caches the
    // last library scan with ABSOLUTE paths into ttuCovers/. Exporting
    // it made the Reader tab paint that stale listing whenever a scan
    // failed, which showed on a restored device as every book present
    // with no cover at all. A scan rebuilds the box anyway.
    expect(AppExportImport.builtinHiveBoxes,
        isNot(contains(ReaderTtuSource.libraryBoxName)),
        reason: 'exporting the scan cache regressed book covers on '
            '2026-09-09; it must be rebuilt by a scan, not restored');
  });

  test('an imported reader font survives a dump/restore round trip',
      () async {
    // The exact shape UserFontsStore writes, with the real values from
    // 白い熊's 2026-09-09 backup: the on-disk name is sanitised ASCII,
    // and the CSS family name comes from the font's OpenType name table.
    const family = 'Source Han Serif JP';
    const onDisk = '_____JP_Heavy_1.0.ttf';
    final indexJson = jsonEncode([
      {
        'name': family,
        'fileName': '源ノ明朝JP_Heavy_1.0.ttf',
        'relativePath': onDisk,
      },
    ]);

    // ---- the source device ----
    final fontsBox = await Hive.openBox(UserFontsStore.boxName);
    await fontsBox.put('entries', indexJson);
    final dump = await AppExportImport.dumpHiveBoxes(
        AppExportImport.builtinHiveBoxes);

    // The dump is what lands in the bundle as hive/boxes.json, so it
    // must survive JSON encoding verbatim.
    final asShipped = jsonDecode(jsonEncode(dump)) as Map<String, dynamic>;
    expect(asShipped.keys, contains(UserFontsStore.boxName));
    expect(asShipped[UserFontsStore.boxName]['entries'], indexJson);

    // ---- the destination device: boxes exist but are empty ----
    await fontsBox.clear();
    expect(fontsBox.get('entries'), isNull);

    await AppExportImport.restoreHiveBoxes(asShipped);

    // ---- what the reader will actually read back ----
    final restored = await Hive.openBox(UserFontsStore.boxName);
    final raw = restored.get('entries') as String?;
    expect(raw, isNotNull,
        reason: 'the font index must be restored, or no @font-face is '
            'injected and the book renders in the default face');
    final entries = (jsonDecode(raw!) as List)
        .cast<Map<dynamic, dynamic>>()
        .map(UserFontEntry.fromJson)
        .toList();
    expect(entries, hasLength(1));
    expect(entries.single.name, family,
        reason: 'the CSS family name the book setting refers to');
    expect(entries.single.relativePath, onDisk,
        reason: 'must match the file shipped in artifacts/user_fonts/');
  });
}
