import 'package:isar_community/isar.dart';

part 'word_list.g.dart';

/// A named list of saved words (Favourites, JLPT N3, …). Its words are
/// [WordListEntry] rows pointing back by [id], so renaming a list
/// touches one row. Kept apart from the Stash, which holds bare strings
/// for the card creator's own use.
@Collection()
class WordList {
  /// Create a list.
  WordList({required this.name, required this.created, this.id});

  /// Identifier for database purposes.
  Id? id;

  /// What the list is called; unique.
  @Index(unique: true)
  String name;

  /// Creation time in milliseconds since the epoch; lists are shown in
  /// this order.
  final int created;
}

/// One word in a [WordList]: the headword and reading it was saved
/// with, so a list keeps 生 (なま) apart from 生 (せい).
@Collection()
class WordListEntry {
  /// Create an entry.
  WordListEntry({
    required this.listId,
    required this.term,
    required this.reading,
    required this.added,
    this.id,
  });

  /// Identifier for database purposes.
  Id? id;

  /// The [WordList] this belongs to. A word appears in a list once.
  @Index(
    composite: [CompositeIndex('term'), CompositeIndex('reading')],
    unique: true,
    replace: true,
  )
  final int listId;

  /// The headword.
  @Index()
  final String term;

  /// Its reading; empty when the dictionary gives none.
  final String reading;

  /// When it was added, in milliseconds since the epoch.
  final int added;
}
