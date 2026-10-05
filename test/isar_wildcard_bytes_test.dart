// Pins down why the Japanese wildcard search expands every `?` to `???`
// (prepareSearchResultsJapaneseLanguage in japanese_language.dart).
//
// Isar's `matches` filter works on UTF-8 BYTES: `?` consumes exactly one
// byte. Kana and BMP kanji are three bytes each, so one typed `?` has to
// become `???` to stand for one character, and the `termLength` index
// (a character count) then pins the result to the typed length. A 2026-10
// audit read `???` as a bug; running the query showed it is the only form
// that matches. If Isar ever switches to character semantics, this test
// fails and the expansion must go.
//
// Needs the desktop libisar.so from the pub cache.

import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shiroikumanojisho/dictionary.dart';

void main() {
  late Isar db;

  setUpAll(() async {
    await Isar.initializeIsarCore(libraries: {
      Abi.linuxX64: '${Platform.environment['HOME']}/.pub-cache/hosted/'
          'pub.dev/isar_community_flutter_libs-3.3.2/linux/libisar.so',
    });
    final dir = Directory.systemTemp.createTempSync('isar_wildcard');
    db = await Isar.open([DictionaryEntrySchema], directory: dir.path);
    DictionaryEntry e(String t, String r) => DictionaryEntry(
        term: t,
        reading: r,
        dictionaryId: 1,
        popularity: 0,
        compressedDefinitions: const []);
    db.writeTxnSync(() => db.dictionaryEntrys.putAllSync([
          e('食べる', 'たべる'),
          e('食う', 'くう'),
          e('食事', 'しょくじ'),
        ]));
  });

  tearDownAll(() => db.close(deleteFromDisk: true));

  List<String> match(String pattern) => db.dictionaryEntrys
      .filter()
      .termMatches(pattern)
      .findAllSync()
      .map((x) => x.term)
      .toList();

  test('a single ? matches one byte, never a Japanese character', () {
    expect(match('食?'), isEmpty);
  });

  test('??? matches exactly one Japanese character', () {
    expect(match('食???'), unorderedEquals(['食う', '食事']));
    expect(match('???う'), ['食う']);
  });

  test('* still spans any number of characters', () {
    expect(match('食*'), unorderedEquals(['食べる', '食う', '食事']));
  });
}
