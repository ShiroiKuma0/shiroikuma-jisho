import 'package:isar_community/isar.dart';

part 'dictionary_kanji.g.dart';

/// One kanji from a Yomitan kanji bank (KANJIDIC and the like), kept with
/// its fields instead of only as the flattened text definition the search
/// results show: readings, meanings and the bank's stats (strokes, grade,
/// JLPT level, frequency, SKIP code, …), which the kanji page displays.
@Collection()
class DictionaryKanji {
  /// Construct a kanji row.
  DictionaryKanji({
    required this.character,
    required this.dictionaryId,
    required this.onyomi,
    required this.kunyomi,
    required this.meanings,
    required this.tags,
    required this.statKeys,
    required this.statValues,
    this.id,
  });

  /// Identifier for database purposes.
  Id? id;

  /// The kanji.
  @Index(type: IndexType.value)
  final String character;

  /// The owning dictionary.
  @Index()
  final int dictionaryId;

  /// On'yomi, in katakana as the bank gives them.
  final List<String> onyomi;

  /// Kun'yomi, with okurigana after a dot (いぬ, あ.げる).
  final List<String> kunyomi;

  /// Meanings, in the bank's language.
  final List<String> meanings;

  /// The bank's tag names (jouyou, …).
  final List<String> tags;

  /// Stat names, parallel to [statValues] (Isar stores no maps).
  final List<String> statKeys;

  /// Stat values, parallel to [statKeys].
  final List<String> statValues;

  /// The value of stat [key], or null.
  String? stat(String key) {
    final i = statKeys.indexOf(key);
    return i < 0 ? null : statValues[i];
  }
}
