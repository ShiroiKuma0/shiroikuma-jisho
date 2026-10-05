import 'dart:convert';

import 'package:isar_community/isar.dart';

part 'dictionary_gloss.g.dart';

/// The English glosses of one [DictionaryEntry], indexed by word so a Latin
/// query can find Japanese headwords by meaning ("eat" → 食べる).
///
/// Definitions are stored compressed and as structured-content JSON, so they
/// cannot be searched in place. This collection is derived from them: it is
/// built by [buildGlossIndexHelper] for every dictionary whose glosses are
/// in a Latin script, is not part of the export bundle, and is rebuilt after
/// a restore. A row with [entryId] == [markerEntryId] records that a
/// dictionary has been indexed, so dictionaries without English glosses are
/// scanned only once.
@Collection()
class DictionaryGloss {
  /// Construct a row.
  DictionaryGloss({
    required this.entryId,
    required this.dictionaryId,
    required this.words,
    required this.glosses,
    this.id,
  });

  /// [entryId] of a dictionary's "indexed" marker row.
  static const int markerEntryId = -1;

  /// Bumped when extraction or normalisation changes, so existing indexes
  /// are rebuilt. Stored in the marker row's [glosses].
  static const String indexVersion = 'v2';

  /// Identifier for database purposes.
  Id? id;

  /// The [DictionaryEntry] these glosses belong to.
  @Index()
  final int entryId;

  /// The owning dictionary, for scoping searches and deleting.
  @Index()
  final int dictionaryId;

  /// Every distinct normalised word across [glosses]. Each element is
  /// indexed, so `wordsElementEqualTo` finds candidate entries.
  @Index(type: IndexType.value)
  final List<String> words;

  /// Normalised glosses as `<sense index>\t<text>`, in dictionary order.
  /// The sense index lets "first meaning" outrank "fifth meaning".
  final List<String> glosses;

  /// Most glosses kept per entry; long entries add noise, not matches.
  static const int maximumGlosses = 40;

  /// Words dropped at the start of a gloss or query: "to eat" and "eat"
  /// should match, as should "a dog" and "dog".
  static const Set<String> _leadingWords = {'to', 'a', 'an', 'the'};

  /// Lower-case [text], drop parenthesised and bracketed asides, keep only
  /// letters, digits and apostrophes, and strip a leading article or the
  /// infinitive "to".
  static String normalise(String text) {
    String s = text.toLowerCase();
    // Innermost first, until none are left: "dog (Canis (lupus)
    // familiaris)" must lose the whole aside, not leave "familiaris".
    final aside = RegExp(r'\([^()]*\)|\[[^\[\]]*\]|\{[^{}]*\}');
    String previous;
    do {
      previous = s;
      s = s.replaceAll(aside, ' ');
    } while (s != previous);
    s = s.replaceAll(RegExp(r"[^\p{L}\p{N}']+", unicode: true), ' ').trim();
    List<String> words = s.split(' ').where((w) => w.isNotEmpty).toList();
    while (words.length > 1 && _leadingWords.contains(words.first)) {
      words.removeAt(0);
    }
    return words.join(' ');
  }

  /// The words of an already [normalise]d string.
  static List<String> tokens(String normalised) =>
      normalised.split(' ').where((w) => w.isNotEmpty).toList();

  /// Whether [text] reads as a Latin-script gloss rather than Japanese,
  /// Chinese or Cyrillic: at least two Latin letters, no CJK or kana, and
  /// mostly Latin among its letters.
  static bool isLatinGloss(String text) {
    int latin = 0;
    int other = 0;
    for (final int c in text.runes) {
      if ((c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A)) {
        latin++;
      } else if (c >= 0x2E80) {
        return false;
      } else if (c >= 0xC0 && c <= 0x24F) {
        latin++;
      } else if (c >= 0x370 && c < 0x2000) {
        other++;
      }
    }
    return latin >= 2 && latin >= other * 4;
  }

  /// Pull `(sense index, gloss)` pairs out of an entry's stored
  /// [definitions] (the decoded form of `compressedDefinitions`).
  ///
  /// Structured content (Jitendex, current JMdict) marks its glosses with
  /// `data: {content: glossary}` lists; each `li` is one gloss and each
  /// glossary list one sense. Only those lists are read, so example
  /// sentences, notes and cross-references never become matches. A plain
  /// string definition is one sense, split on `;`, and is read only when
  /// it is entirely Latin script.
  static List<(int, String)> extractGlosses(List<String> definitions) {
    final out = <(int, String)>[];
    int sense = 0;

    for (final String definition in definitions) {
      final String trimmed = definition.trimLeft();
      if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
        Object? node;
        try {
          node = jsonDecode(trimmed);
        } catch (_) {
          node = null;
        }
        if (node != null) {
          void walk(Object? n) {
            if (n is List) {
              for (final child in n) {
                walk(child);
              }
            } else if (n is Map) {
              final data = n['data'];
              if (data is Map && data['content'] == 'glossary') {
                final items = n['content'];
                for (final item in items is List ? items : [items]) {
                  final text = _flatten(item).trim();
                  if (text.isNotEmpty) {
                    out.add((sense, text));
                  }
                }
                sense++;
              } else {
                walk(n['content']);
              }
            }
          }

          walk(node);
          continue;
        }
      }

      // Only a wholly English definition is a gloss list. Japanese–English
      // dictionaries such as 新和英大辞典 write running text that mixes
      // Japanese explanations, examples and English: split on ";", a
      // fragment like "dog" out of 狙う's "shadow; follow; tail; dog"
      // became an exact match and outranked 犬.
      if (isLatinGloss(definition)) {
        for (final String part in definition.split(';')) {
          final text = part.trim();
          if (text.isNotEmpty) {
            out.add((sense, text));
          }
        }
      }
      sense++;
    }

    return out;
  }

  static String _flatten(Object? node) {
    if (node is String) return node;
    if (node is List) return node.map(_flatten).join();
    if (node is Map) return _flatten(node['content']);
    return '';
  }

  /// Build the row for one entry, or null when it has no Latin glosses.
  static DictionaryGloss? forEntry({
    required int entryId,
    required int dictionaryId,
    required List<String> definitions,
  }) {
    final glosses = <String>[];
    final words = <String>{};

    for (final (int sense, String text) in extractGlosses(definitions)) {
      if (glosses.length >= maximumGlosses) break;
      if (!isLatinGloss(text)) continue;
      final normalised = normalise(text);
      if (normalised.isEmpty) continue;
      glosses.add('$sense\t$normalised');
      words.addAll(tokens(normalised));
    }

    if (glosses.isEmpty) return null;
    return DictionaryGloss(
      entryId: entryId,
      dictionaryId: dictionaryId,
      words: words.toList(),
      glosses: glosses,
    );
  }
}
