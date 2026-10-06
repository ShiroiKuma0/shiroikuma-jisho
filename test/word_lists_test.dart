// Word list storage and the CSV/TSV a list exports to. Needs the desktop
// libisar.so from the pub cache.

import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/utils.dart';

void main() {
  late Isar db;

  setUpAll(() async {
    await Isar.initializeIsarCore(libraries: {
      Abi.linuxX64: '${Platform.environment['HOME']}/.pub-cache/hosted/'
          'pub.dev/isar_community_flutter_libs-3.3.2/linux/libisar.so',
    });
    final dir = Directory.systemTemp.createTempSync('word_lists');
    db = await Isar.open([WordListSchema, WordListEntrySchema],
        directory: dir.path);
  });

  test('lists hold a word once per reading', () {
    final favourites = WordLists.all(db).single;
    expect(favourites.name, WordLists.defaultName);
    final n3 = WordLists.create(db, 'N3')!;
    expect(WordLists.create(db, ' N3 '), isNull);

    WordLists.set(db, favourites.id!, '生', 'なま', present: true);
    WordLists.set(db, favourites.id!, '生', 'なま', present: true);
    WordLists.set(db, favourites.id!, '生', 'せい', present: true);
    WordLists.set(db, n3.id!, '生', 'なま', present: true);
    expect(WordLists.count(db, favourites), 2);
    expect(WordLists.listsContaining(db, '生', 'なま'),
        {favourites.id, n3.id});

    WordLists.set(db, n3.id!, '生', 'なま', present: false);
    expect(WordLists.listsContaining(db, '生', 'なま'), {favourites.id});

    expect(WordLists.rename(db, n3, WordLists.defaultName), isFalse);
    expect(WordLists.rename(db, n3, 'JLPT N3'), isTrue);
    WordLists.set(db, n3.id!, '食べる', 'たべる', present: true);
    WordLists.delete(db, n3);
    expect(WordLists.all(db).map((l) => l.name), [WordLists.defaultName]);
    expect(WordLists.listsContaining(db, '食べる', 'たべる'), isEmpty);
  });

  test('CSV quotes what needs quoting; TSV flattens', () {
    final rows = [
      ['食べる', 'たべる', 'to eat; to live on, "subsist"'],
      ['猫', 'ねこ', 'cat\tfeline\nanimal'],
    ];
    expect(
      WordLists.delimited(rows, tab: false),
      'term,reading,meaning\r\n'
      '食べる,たべる,"to eat; to live on, ""subsist"""\r\n'
      '猫,ねこ,"cat\tfeline\nanimal"\r\n',
    );
    expect(
      WordLists.delimited(rows, tab: true).split('\r\n')[2],
      '猫\tねこ\tcat feline animal',
    );
  });
}
