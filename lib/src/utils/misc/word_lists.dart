import 'package:collection/collection.dart';
import 'package:isar_community/isar.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/models.dart';

/// Named word lists: storage helpers over [WordList] and [WordListEntry],
/// plus the CSV/TSV a list exports to.
class WordLists {
  WordLists._();

  /// The list made on first use, so the ★ button always has somewhere
  /// to put a word.
  static const String defaultName = 'Favourites';

  /// Every list, oldest first; creates [defaultName] when there are none.
  static List<WordList> all(Isar db) {
    final lists = db.wordLists.where().findAllSync()
      ..sort((a, b) => a.created.compareTo(b.created));
    if (lists.isNotEmpty) return lists;
    return [create(db, defaultName)!];
  }

  /// Make a list called [name]; null when the name is blank or taken.
  static WordList? create(Isar db, String name) {
    name = name.trim();
    if (name.isEmpty || db.wordLists.getByNameSync(name) != null) return null;
    final list = WordList(
        name: name, created: DateTime.now().millisecondsSinceEpoch);
    db.writeTxnSync(() => db.wordLists.putSync(list));
    return list;
  }

  /// Rename [list] to [name]; false when the name is blank or taken.
  static bool rename(Isar db, WordList list, String name) {
    name = name.trim();
    if (name.isEmpty) return false;
    final existing = db.wordLists.getByNameSync(name);
    if (existing != null && existing.id != list.id) return false;
    list.name = name;
    db.writeTxnSync(() => db.wordLists.putSync(list));
    return true;
  }

  /// Delete [list] and its words.
  static void delete(Isar db, WordList list) {
    db.writeTxnSync(() {
      db.wordListEntrys
          .where()
          .listIdEqualToAnyTermReading(list.id!)
          .deleteAllSync();
      db.wordLists.deleteSync(list.id!);
    });
  }

  /// The words in [list], in the order they were added.
  static List<WordListEntry> entries(Isar db, WordList list) =>
      db.wordListEntrys
          .where()
          .listIdEqualToAnyTermReading(list.id!)
          .findAllSync()
        ..sort((a, b) => a.added.compareTo(b.added));

  /// How many words [list] holds.
  static int count(Isar db, WordList list) => db.wordListEntrys
      .where()
      .listIdEqualToAnyTermReading(list.id!)
      .countSync();

  /// Ids of the lists holding [term] read as [reading].
  static Set<int> listsContaining(Isar db, String term, String reading) =>
      db.wordListEntrys
          .where()
          .termEqualTo(term)
          .findAllSync()
          .where((e) => e.reading == reading)
          .map((e) => e.listId)
          .toSet();

  /// Add [term] / [reading] to the list [listId], or take it out.
  static void set(Isar db, int listId, String term, String reading,
      {required bool present}) {
    db.writeTxnSync(() {
      if (present) {
        db.wordListEntrys.putSync(WordListEntry(
          listId: listId,
          term: term,
          reading: reading,
          added: DateTime.now().millisecondsSinceEpoch,
        ));
      } else {
        db.wordListEntrys
            .where()
            .listIdTermReadingEqualTo(listId, term, reading)
            .deleteAllSync();
      }
    });
  }

  /// Remove one entry.
  static void remove(Isar db, WordListEntry entry) =>
      db.writeTxnSync(() => db.wordListEntrys.deleteSync(entry.id!));

  /// Put [entry] back after a [remove].
  static void restore(Isar db, WordListEntry entry) =>
      db.writeTxnSync(() => db.wordListEntrys.putSync(entry));

  /// The dictionary heading for [entry], looked up afresh so it carries
  /// the current dictionaries' definitions; null when no dictionary has
  /// the word any more.
  static Future<DictionaryHeading?> heading(
      AppModel appModel, WordListEntry entry) async {
    final result = await appModel.searchDictionary(
      searchTerm: entry.term,
      searchWithWildcards: false,
    );
    final headings = result.headings.where((h) => h.term == entry.term);
    return headings.firstWhereOrNull((h) => h.reading == entry.reading) ??
        headings.firstOrNull;
  }

  /// [heading]'s definitions from its first dictionary, on one line
  /// separated by semicolons.
  static String meaning(AppModel appModel, DictionaryHeading heading) {
    final first = heading.entries.firstOrNull?.dictionary.value?.name;
    final definitions = <String>[];
    for (final entry in heading.entries) {
      if (entry.dictionary.value?.name != first) continue;
      final format = appModel.getDictionaryFormat(entry.dictionary.value!);
      for (var d in entry.definitions) {
        if (format.shouldUseCustomDefinitionWidget(d)) {
          d = format.getCustomDefinitionText(d);
        }
        d = d.replaceAll(RegExp(r'\s*\n\s*'), '; ').trim();
        if (d.isNotEmpty) definitions.add(d);
      }
    }
    return definitions.join('; ');
  }

  /// Rows of term, reading, meaning as CSV (RFC 4180, with a header) or,
  /// when [tab] is set, as TSV with tabs and newlines inside fields
  /// turned into spaces.
  static String delimited(List<List<String>> rows, {required bool tab}) {
    String field(String s) {
      if (tab) return s.replaceAll(RegExp(r'[\t\r\n]+'), ' ');
      if (!s.contains(RegExp(r'[",\r\n]'))) return s;
      return '"${s.replaceAll('"', '""')}"';
    }

    final buffer = StringBuffer();
    for (final row in [
      ['term', 'reading', 'meaning'],
      ...rows,
    ]) {
      buffer.write(row.map(field).join(tab ? '\t' : ','));
      buffer.write('\r\n');
    }
    return buffer.toString();
  }
}
