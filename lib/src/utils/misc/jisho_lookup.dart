import 'dart:convert';

import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:collection/collection.dart';
import 'package:isar_community/isar.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/language.dart';
import 'package:shiroikumanojisho/models.dart';
import 'package:shiroikumanojisho/pages.dart';
import 'package:shiroikumanojisho/src/language/implementations/japanese_conjugation.dart';
import 'package:shiroikumanojisho/utils.dart';

/// The batch lookup door for sister apps: everything this app knows about
/// a list of `{term, reading}` pairs, as JSON. 自由作業盤 asks once per
/// term while it imports a 言語島 vocabulary and caches the answer, so it
/// never has to wake this app again while 白い熊 browses.
///
/// Runs inside the headless engine [LookupEngine] (Java) keeps warm
/// between batches; the native side identifies the caller and moves the
/// bytes. The contract — names, schema, errors, timeouts — is
/// `docs/sister-app-contract-jisho-lookup.md`; change both together.
///
/// Every field mirrors what the result card shows (DictionaryTermPage):
/// the same dictionaries, in the user's order, minus those hidden for
/// Japanese.
class JishoLookup {
  JishoLookup._();

  /// The contract version. Bumped only when an answer changes in a way
  /// an existing caller would misread; added fields do not bump it.
  static const int contractVersion = 1;

  /// Most items one call may carry.
  static const int maximumItems = 100;

  /// Most example sentences per item.
  static const int maximumExamples = 10;

  /// Japanese, or null when no Japanese language is installed.
  static Language? _japanese(AppModel appModel) =>
      appModel.languageForCode('ja');

  /// Dictionaries searched for Japanese, as the search itself decides.
  static bool _enabled(Dictionary d) =>
      !d.hiddenLanguages.contains('ja') &&
      (d.primaryLanguage.isEmpty || d.primaryLanguage == 'ja');

  /// The capability answer: what this build can look up, and with what.
  static Map<String, Object?> describe(AppModel appModel) {
    final dictionaries = [...appModel.dictionaries]
      ..sort((a, b) => a.order.compareTo(b.order));
    return {
      'lookup_version': contractVersion,
      'version_name': appModel.packageInfo.version,
      'version_code': int.tryParse(appModel.packageInfo.buildNumber),
      'max_items': maximumItems,
      'japanese_installed': _japanese(appModel) != null,
      'examples_installed': appModel.database.exampleSentences.countSync() > 0,
      'dictionaries': [
        for (final d in dictionaries) {'name': d.name, 'enabled': _enabled(d)},
      ],
    };
  }

  /// Look every item of [request] up; the answer keeps request order.
  /// Throws [FormatException] for a request this contract cannot read —
  /// the entry point turns that into an `ERROR:` line.
  static Future<Map<String, Object?>> lookup(
    AppModel appModel,
    String request,
  ) async {
    final Object? decoded = jsonDecode(request);
    if (decoded is! Map) throw const FormatException('request is not an object');
    final language = decoded['language'] ?? 'ja';
    if (language != 'ja') {
      throw FormatException('language not supported: $language');
    }
    final items = decoded['items'];
    if (items is! List) throw const FormatException('items missing');
    if (items.length > maximumItems) {
      throw FormatException(
          'too many items: ${items.length} > $maximumItems');
    }
    final Language? japanese = _japanese(appModel);
    if (japanese == null) {
      throw const FormatException('japanese not installed');
    }
    if (appModel.dictionaryLanguage.languageCode != 'ja') {
      await appModel.setDictionaryLanguageOverride(japanese);
    }

    final answers = <Map<String, Object?>>[];
    for (final item in items) {
      final term = item is Map ? '${item['term'] ?? ''}'.trim() : '';
      final reading = item is Map ? '${item['reading'] ?? ''}'.trim() : '';
      answers.add(await _lookupOne(appModel, term, reading));
    }
    return {
      'lookup_version': contractVersion,
      'version_name': appModel.packageInfo.version,
      'items': answers,
    };
  }

  static Future<Map<String, Object?>> _lookupOne(
    AppModel appModel,
    String term,
    String reading,
  ) async {
    final miss = {'term': term, 'reading': reading, 'found': false};
    if (term.isEmpty) return miss;

    final result = await appModel.searchDictionary(
      searchTerm: term,
      searchWithWildcards: false,
    );
    final DictionaryHeading? heading =
        _match(result.headings, term, reading);
    if (heading == null) return miss;

    final Isar db = appModel.database;
    bool visible(Dictionary? d) => d != null && _enabled(d);
    int order(Dictionary? d) => d?.order ?? 1 << 30;

    final entries =
        heading.entries.where((e) => visible(e.dictionary.value)).toList()
          ..sort((a, b) =>
              order(a.dictionary.value).compareTo(order(b.dictionary.value)));
    if (entries.isEmpty) return miss;

    // Pitch: distinct downsteps across the pitch dictionaries, in order,
    // at most two — the result card's header line.
    final pitches =
        heading.pitches.where((p) => visible(p.dictionary.value)).toList()
          ..sort((a, b) =>
              order(a.dictionary.value).compareTo(order(b.dictionary.value)));
    final downsteps = <int>[];
    for (final p in pitches) {
      if (!downsteps.contains(p.downstep)) downsteps.add(p.downstep);
    }

    // Other written forms, from the first dictionary that lists them.
    final forms = <String>[];
    for (final entry in entries) {
      final found = extractWrittenForms(entry.definitions);
      if (found.isEmpty) continue;
      for (final form in found) {
        if (form != heading.term && !forms.contains(form)) forms.add(form);
      }
      break;
    }

    // Senses per dictionary, plain text.
    final glosses = <Map<String, Object?>>[];
    final byDictionary = <String, List<String>>{};
    for (final entry in entries) {
      final name = entry.dictionary.value!.name;
      byDictionary.putIfAbsent(name, () => []).addAll(_senses(entry));
    }
    byDictionary.forEach((name, senses) {
      if (senses.isNotEmpty) {
        glosses.add({'dictionary': name, 'senses': senses});
      }
    });

    final frequencies = [
      ...heading.frequencies,
      ...appModel.getNoReadingFrequencies(heading: heading),
    ].where((f) => visible(f.dictionary.value)).toList()
      ..sort((a, b) =>
          order(a.dictionary.value).compareTo(order(b.dictionary.value)));
    final DictionaryFrequency? frequency = frequencies.firstOrNull;

    final allCodes = partOfSpeechCodes(entries);
    final String? conjugationClass = JapaneseConjugation.classOf(allCodes);
    final conjugation = conjugationClass == null
        ? null
        : JapaneseConjugation.table(heading.term, conjugationClass);

    final examples = ExampleSentences.forWord(
      db,
      heading.term,
      heading.reading,
      limit: maximumExamples,
    );

    return {
      'term': term,
      'reading': reading,
      'found': true,
      'headword': heading.term,
      'headword_reading': heading.reading,
      'pitch': downsteps.take(2).toList(),
      'forms': forms,
      'pos': partOfSpeechCodes(entries, includeHeadingTags: false)
          .where((c) => c.isNotEmpty)
          .toList(),
      'glosses': glosses,
      'frequency': frequency == null ? null : _rank(frequency.displayValue),
      'frequency_dictionary': frequency?.dictionary.value?.name,
      'tags': [
        for (final tag in {for (final t in heading.tags) t.name: t}.values)
          {'name': tag.name, 'notes': tag.notes},
      ],
      'kanji': _kanji(appModel, heading.term),
      'examples': [
        for (final e in examples) {'ja': e.japanese, 'en': e.english},
      ],
      if (conjugation != null) 'conjugation_class': conjugationClass,
      if (conjugation != null)
        'conjugation': [
          for (final row in conjugation)
            {
              'form': row.$1,
              'plain': row.$2,
              'plain_negative': row.$3,
              'polite': row.$4,
              'polite_negative': row.$5,
            },
        ],
    };
  }

  /// The heading for exactly [term] — and [reading], when one is given,
  /// compared with katakana folded to hiragana. The search also returns
  /// deinflected and prefix matches; none of those is the asked word.
  static DictionaryHeading? _match(
    List<DictionaryHeading> headings,
    String term,
    String reading,
  ) {
    final wanted = _hiragana(reading);
    final sameTerm = headings.where((h) => h.term == term).toList();
    if (reading.isEmpty) return sameTerm.firstOrNull;
    return sameTerm.firstWhereOrNull(
          (h) => _hiragana(h.reading.isEmpty ? h.term : h.reading) == wanted,
        ) ??
        // A kana headword asked for by its own spelling.
        sameTerm.firstWhereOrNull(
          (h) => h.reading.isEmpty && _hiragana(term) == wanted,
        );
  }

  /// [text] with katakana folded to hiragana.
  static String _hiragana(String text) => String.fromCharCodes(
        text.runes.map((c) => c >= 0x30A1 && c <= 0x30F6 ? c - 0x60 : c),
      );

  /// One entry's senses as plain strings: the English glosses of each
  /// sense joined with "; " (the gloss index's own extraction), or, for a
  /// dictionary with no English glosses, each definition flattened to
  /// its text.
  static List<String> _senses(DictionaryEntry entry) {
    final pairs = DictionaryGloss.extractGlosses(entry.definitions);
    if (pairs.isNotEmpty) {
      final senses = <int, List<String>>{};
      for (final (sense, gloss) in pairs) {
        senses.putIfAbsent(sense, () => []).add(gloss);
      }
      return [for (final g in senses.values) g.join('; ')];
    }
    return entry.definitions
        .map(_flatten)
        .map((t) => t.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// A stored definition as text: structured content is JSON, kept as a
  /// string, whose text sits in nested `content` fields.
  static String _flatten(String definition) {
    final trimmed = definition.trimLeft();
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      try {
        return _text(jsonDecode(trimmed));
      } catch (_) {
        // Not JSON after all: plain text that starts with a bracket.
      }
    }
    return definition;
  }

  static String _text(Object? node) {
    if (node is String) return node;
    if (node is List) return node.map(_text).join(' ');
    if (node is Map) {
      // A list item or a block is its own line of text.
      return _text(node['content']);
    }
    return '';
  }

  /// The first figure of a frequency's display value ("1462, 33889㋕" →
  /// 1462), as the result card shows it.
  static int? _rank(String displayValue) =>
      int.tryParse(displayValue.split(RegExp(r'[,，、\s]')).first);

  /// Each kanji of [term] with its KANJIDIC data and frequency rank,
  /// as the kanji page shows them.
  static List<Map<String, Object?>> _kanji(AppModel appModel, String term) {
    final Isar db = appModel.database;
    final Map<int, Dictionary> dictionaries = {
      for (final d in appModel.dictionaries) d.id: d,
    };
    bool visible(int id) =>
        dictionaries[id] != null && _enabled(dictionaries[id]!);

    final characters = <String>[];
    for (final c in term.characters) {
      if (KanjiBreakdown.isKanji(c) && c != '々' && !characters.contains(c)) {
        characters.add(c);
      }
    }
    return [
      for (final c in characters) _oneKanji(db, c, visible, dictionaries),
    ];
  }

  static Map<String, Object?> _oneKanji(
    Isar db,
    String character,
    bool Function(int) visible,
    Map<int, Dictionary> dictionaries,
  ) {
    final rows = db.dictionaryKanjis
        .where()
        .characterEqualTo(character)
        .findAllSync()
        .where((k) => visible(k.dictionaryId))
        .toList()
      ..sort((a, b) => dictionaries[a.dictionaryId]!.order
          .compareTo(dictionaries[b.dictionaryId]!.order));
    final DictionaryKanji? main = rows.firstOrNull;
    final frequency = db.dictionaryFrequencys
        .where()
        .termEqualTo(character)
        .findAllSync()
        .where((f) => f.reading.isEmpty && visible(f.dictionaryId))
        .sortedBy<num>((f) => dictionaries[f.dictionaryId]!.order)
        .firstOrNull;
    int? stat(String key) => int.tryParse(main?.stat(key) ?? '');
    return {
      'char': character,
      'meanings': main?.meanings ?? const <String>[],
      'on': main?.onyomi ?? const <String>[],
      'kun': main?.kunyomi ?? const <String>[],
      'strokes': stat('strokes'),
      'grade': stat('grade'),
      'jlpt': stat('jlpt'),
      'frequency': frequency == null ? null : _rank(frequency.displayValue),
      'newspaper_rank': stat('freq'),
    };
  }
}
