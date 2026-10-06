import 'package:isar_community/isar.dart';

part 'example_sentence.g.dart';

/// A Japanese–English example sentence pair from the Tanaka Corpus
/// (Tatoeba, as EDRDG's examples.utf), indexed by the dictionary forms of
/// the words it contains so a headword finds its examples directly.
/// Downloaded on request (ExampleSentences); not part of the export
/// bundle.
@Collection()
class ExampleSentence {
  /// Construct a pair.
  ExampleSentence({
    required this.japanese,
    required this.english,
    required this.words,
    required this.surfaces,
    this.id,
  });

  /// Identifier for database purposes.
  Id? id;

  /// The Japanese sentence.
  final String japanese;

  /// Its English translation.
  final String english;

  /// Dictionary forms and readings of the words in [japanese], from the
  /// corpus's B-line (会う, 事, こと, …). Each element is indexed.
  @Index(type: IndexType.value)
  final List<String> words;

  /// For each dictionary form in [words] that appears inflected or in
  /// kana in the sentence, `form\tsurface` (無い\tない), so the word can be
  /// highlighted as written.
  final List<String> surfaces;
}
