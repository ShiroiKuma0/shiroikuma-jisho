import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:ve_dart/ve_dart.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/language.dart';
import 'package:shiroikumanojisho/models.dart';
import 'package:shiroikumanojisho/src/language/implementations/japanese_transformer.dart';

/// Language implementation of the Japanese language.
class JapaneseLanguage extends Language {
  JapaneseLanguage._privateConstructor()
    : super(
        languageName: '日本語',
        languageCode: 'ja',
        countryCode: 'JP',
        threeLetterCode: 'jpn',
        preferVerticalReading: true,
        textDirection: TextDirection.ltr,
        isSpaceDelimited: false,
        textBaseline: TextBaseline.ideographic,
        prepareSearchResults: prepareSearchResultsJapaneseLanguage,
        helloWorld: 'こんにちは世界',
        standardFormat: YomichanFormat.instance,
        defaultFontFamily: 'NotoSansJP',
      );

  /// Get the singleton instance of this language.
  static JapaneseLanguage get instance => _instance;

  static final JapaneseLanguage _instance =
      JapaneseLanguage._privateConstructor();

  /// Used for text segmentation and deinflection.
  static Mecab mecab = Mecab();

  /// Used for processing Japanese characters from Kana to Romaji and so on.
  static KanaKit kanaKit = const KanaKit();

  /// Used to cache furigana segments for already generated
  /// [DictionaryHeading] items. Re-key is straightforward because the
  /// plain `DictionaryHeading` class uses value equality on
  /// `(term, reading)`.
  final Map<DictionaryHeading, List<RubyTextData>?> segmentsCache = {};

  @override
  Future<void> prepareResources() async {
    await mecab.init('assets/language/japanese/ipadic', true);
  }

  @override
  List<String> textToWords(String text) {
    String delimiterSanitisedText = text
        .replaceAll('﻿', '␝')
        .replaceAll('　', '␝')
        .replaceAll('\n', '␜')
        .replaceAll(' ', '␝');

    List<Word> tokens = parseVe(mecab, delimiterSanitisedText);

    List<String> terms = [];

    for (Word token in tokens) {
      final buffer = StringBuffer();
      for (TokenNode token in token.tokens) {
        buffer.write(token.surface);
      }

      String term = buffer.toString();
      term = term.replaceAll('␜', '\n').replaceAll('␝', ' ');
      terms.add(term);
    }

    return terms;
  }

  /// Display the term with furigana from its reading.
  @override
  Widget getTermReadingOverrideWidget({
    required BuildContext context,
    required AppModel appModel,
    required DictionaryHeading heading,
    required Function(String) onSearch,
  }) {
    TextStyle indexStyle(int index, String character) {
      if (kanaKit.isKanji(character)) {
        return const TextStyle(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
        );
      } else {
        return const TextStyle();
      }
    }

    void indexAction(int index, String character) {
      if (kanaKit.isKanji(character)) {
        onSearch(character);
      }
    }

    if (heading.reading.isEmpty) {
      return RubyText(
        [RubyTextData(heading.term)],
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: appModel.dictionaryHeadingFontSize,
          fontFamily: appModel.dictionaryHeadingFontFamily.isEmpty
              ? null
              : appModel.dictionaryHeadingFontFamily,
          color: Color(appModel.dictionaryFontColor),
        ),
        rubyStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: appModel.dictionaryHeadingRubyFontSize,
          color: Color(appModel.dictionaryFontColor),
        ),
        indexAction: indexAction,
        indexStyle: indexStyle,
      );
    }

    List<RubyTextData>? segments = fetchFurigana(heading: heading);
    return RubyText(
      segments ?? [RubyTextData(heading.term, ruby: heading.reading)],
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: appModel.dictionaryHeadingFontSize,
        fontFamily: appModel.dictionaryHeadingFontFamily.isEmpty
            ? null
            : appModel.dictionaryHeadingFontFamily,
        color: Color(appModel.dictionaryFontColor),
      ),
      rubyStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: appModel.dictionaryHeadingRubyFontSize,
        color: Color(appModel.dictionaryFontColor),
      ),
      indexAction: indexAction,
      indexStyle: indexStyle,
    );
  }

  /// Fetch furigana for a heading with memoisation.
  List<RubyTextData>? fetchFurigana({required DictionaryHeading heading}) {
    if (segmentsCache.containsKey(heading)) {
      return segmentsCache[heading];
    }
    final furigana = LanguageUtils.distributeFurigana(heading: heading);
    segmentsCache[heading] = furigana;
    return furigana;
  }

  @override
  Widget getPitchWidget({
    required AppModel appModel,
    required BuildContext context,
    required String reading,
    required int downstep,
  }) {
    List<Widget> listWidgets = [];

    Color color = Theme.of(context).brightness == Brightness.dark
        ? Color(appModel.dictionaryFontColor)
        : Colors.black;

    Widget getAccentTop(String text) {
      return Container(
        padding: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: color)),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: appModel.dictionaryFontSize),
        ),
      );
    }

    Widget getAccentEnd(String text) {
      return Container(
        padding: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: color),
            right: BorderSide(color: color),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: appModel.dictionaryFontSize),
        ),
      );
    }

    Widget getAccentNone(String text) {
      return Container(
        padding: const EdgeInsets.only(top: 1),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.transparent)),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: appModel.dictionaryFontSize),
        ),
      );
    }

    List<String> moras = [];
    for (int i = 0; i < reading.length; i++) {
      String current = reading[i];
      String? next;
      if (i + 1 < reading.length) {
        next = reading[i + 1];
      }

      if (next != null && 'ゃゅょぁぃぅぇぉャュョァィゥェォ'.contains(next)) {
        moras.add(current + next);
        i += 1;
        continue;
      } else {
        moras.add(current);
      }
    }

    if (downstep == 0) {
      for (int i = 0; i < moras.length; i++) {
        if (i == 0) {
          listWidgets.add(getAccentNone(moras[i]));
        } else {
          listWidgets.add(getAccentTop(moras[i]));
        }
      }
    } else {
      for (int i = 0; i < moras.length; i++) {
        if (i == 0 && i != downstep - 1) {
          listWidgets.add(getAccentNone(moras[i]));
        } else if (i < downstep - 1) {
          listWidgets.add(getAccentTop(moras[i]));
        } else if (i == downstep - 1) {
          listWidgets.add(getAccentEnd(moras[i]));
        } else {
          listWidgets.add(getAccentNone(moras[i]));
        }
      }
    }

    listWidgets.add(
      Text(
        ' [$downstep]  ',
        style: TextStyle(color: color, fontSize: appModel.dictionaryFontSize),
      ),
    );

    Widget widget = Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: listWidgets,
    );

    return widget;
  }
}

/// Top-level function for use in compute.
/// Credits to Matthew Chan for their port of the Yomichan parser to Dart.
///
/// Search pipeline (flat schema):
///   1. Normalise input: romaji → hiragana; truncate at 20 chars.
///   2. Open Isar.
///   3. Populate a [SearchResultBuilder] by running a sequence of queries
///      against the flat `DictionaryEntry` collection:
///        * wildcard path — `termMatches` and, for kana-only inputs,
///          `readingMatches` (with an optional katakana→hiragana variant)
///        * non-wildcard path — progressive prefix shortening; at each
///          length:
///            • termExact (optional katakana→hiragana fallback)
///            • readingExact (if the partial is kana)
///            • termDeinflected via [Deinflector.deinflect]
///            • readingDeinflected (if the partial is kana)
///            • termExactKatakana (if the partial is hiragana)
///          plus a startsWith fallback once any match has been found.
///   4. Post-sort groups: within the set of groups sharing the same term
///      or reading, apply the multi-criteria Japanese ordering
///      (Yomichan-style: 'P' tag boost, frequency-by-dictionary-order,
///      popularity sum, entry count, insertion order).
///   5. Single-kanji prioritisation: if the query is a single kanji, the
///      (term=<kanji>, reading='') group is promoted to position 0.
///   6. Trim and materialise via
///      [SearchResultBuilder.buildFromOrderedGroups].
Future<SearchResultData?> prepareSearchResultsJapaneseLanguage(
  DictionarySearchParams params,
) async {
  final String query = params.searchTerm.trim();
  if (!_latinQuery.hasMatch(query)) {
    return _prepareSearchResultsJapaneseTerms(params);
  }

  // A Latin query is either romaji or English, and often could be both
  // ("sake", "mine"). Search it both ways. Whichever reading matches the
  // whole query goes first; the other keeps at least half the slots.
  const kanaKit = KanaKit();
  final String kana = kanaKit.toHiragana(query.toLowerCase());
  final bool isRomaji = kana.isNotEmpty && kanaKit.isKana(kana);

  final SearchResultData? japanese = isRomaji
      ? await _prepareSearchResultsJapaneseTerms(params)
      : null;

  final database =
      Isar.getInstance() ??
      await Isar.open(
        globalSchemas,
        directory: params.directoryPath,
        maxSizeMiB: 8192,
      );
  final SearchResultData? english = searchJapaneseByEnglishGloss(
    database: database,
    query: query,
    maxGroups: params.maximumDictionaryTermsInResult,
    enabledDictionaryIds: params.enabledDictionaryIds,
  );

  if (japanese == null) return english;
  if (english == null) return japanese;

  final bool romajiMatchesWhole = japanese.bestLength >= kana.length;
  return _mergeSearchResults(
    first: romajiMatchesWhole ? japanese : english,
    second: romajiMatchesWhole ? english : japanese,
    maxGroups: params.maximumDictionaryTermsInResult,
  );
}

/// Letters, spaces, apostrophes and hyphens only — a query that could be
/// English or romaji. Wildcard queries never match, so they keep their
/// own path.
final RegExp _latinQuery = RegExp(r"^[A-Za-z][A-Za-z' \-]*$");

/// Concatenate two results without repeating a headword. [second] keeps up
/// to half of [maxGroups] when it has that many, so a full first list
/// cannot push it out entirely.
SearchResultData _mergeSearchResults({
  required SearchResultData first,
  required SearchResultData second,
  required int maxGroups,
}) {
  final int reserved = second.groups.length < maxGroups ~/ 2
      ? second.groups.length
      : maxGroups ~/ 2;
  final seen = <String>{};
  final groups = <EntryGroup>[];

  for (final g in first.groups) {
    if (groups.length >= maxGroups - reserved) break;
    if (seen.add('${g.term}\u0001${g.reading}')) groups.add(g);
  }
  for (final g in second.groups) {
    if (groups.length >= maxGroups) break;
    if (seen.add('${g.term}\u0001${g.reading}')) groups.add(g);
  }

  return SearchResultData(
    searchTerm: first.searchTerm,
    bestLength: first.bestLength > second.bestLength
        ? first.bestLength
        : second.bestLength,
    groups: groups,
  );
}

/// English → Japanese: find headwords whose English glosses contain every
/// word of [query], best matches first.
///
/// Candidates come from the [DictionaryGloss] word index (probed with the
/// longest query word, the likeliest to be rare). Each candidate entry is
/// scored by its best gloss:
///   tier 0 — the gloss is the query ("eat" for "to eat")
///   tier 1 — the gloss starts with the query ("eat up", "give up smoking")
///   tier 2 — the gloss contains every query word
/// then by how early that sense comes, then by frequency rank, then by the
/// dictionary's own popularity score. Only [enabledDictionaryIds] are
/// searched, so dictionaries hidden for Japanese never answer.
SearchResultData? searchJapaneseByEnglishGloss({
  required Isar database,
  required String query,
  required int maxGroups,
  required List<int> enabledDictionaryIds,
}) {
  final String normalised = DictionaryGloss.normalise(query);
  final List<String> words = DictionaryGloss.tokens(normalised);
  if (words.isEmpty) return null;

  final String probe = words.reduce((a, b) => b.length > a.length ? b : a);
  // Only fully indexed dictionaries answer: rows of a dictionary without a
  // current marker are partial or stale.
  final Set<int> indexed = DictionaryGloss.indexedDictionaryIds(database);
  final Set<int> enabled = enabledDictionaryIds.isEmpty
      ? indexed
      : enabledDictionaryIds.toSet().intersection(indexed);
  if (enabled.isEmpty) return null;

  final rows = database.dictionaryGloss
      .where()
      .wordsElementEqualTo(probe)
      .limit(5000)
      .findAllSync();

  // entryId → (tier, sense bucket)
  final scores = <int, (int, int)>{};
  for (final DictionaryGloss row in rows) {
    if (!enabled.contains(row.dictionaryId)) continue;
    if (!words.every(row.words.contains)) continue;

    (int, int)? best;
    for (final String stored in row.glosses) {
      final int tab = stored.indexOf('\t');
      final int sense = int.tryParse(stored.substring(0, tab)) ?? 99;
      final String text = stored.substring(tab + 1);

      int tier;
      if (text == normalised) {
        tier = 0;
      } else if (text.startsWith('$normalised ')) {
        tier = 1;
      } else if (words.every(DictionaryGloss.tokens(text).contains)) {
        tier = 2;
      } else {
        continue;
      }
      final int senseBucket = sense == 0 ? 0 : (sense <= 2 ? 1 : 2);
      final (int, int) score = (tier, senseBucket);
      if (best == null ||
          score.$1 < best.$1 ||
          (score.$1 == best.$1 && score.$2 < best.$2)) {
        best = score;
      }
    }
    if (best == null) continue;

    final previous = scores[row.entryId];
    if (previous == null ||
        best.$1 < previous.$1 ||
        (best.$1 == previous.$1 && best.$2 < previous.$2)) {
      scores[row.entryId] = best;
    }
  }
  if (scores.isEmpty) return null;

  int compareScore((int, int) a, (int, int) b) =>
      a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2);

  // Walk the candidates best-first until there are enough headwords to
  // rank; only those get the frequency lookup.
  final shortlist = scores.keys.toList()
    ..sort((a, b) => compareScore(scores[a]!, scores[b]!));
  final int wantedGroups = maxGroups * 4;
  final groupScore = <String, (int, int)>{};
  final groupEntries = <String, List<DictionaryEntry>>{};
  const int chunk = 100;
  for (
    int start = 0;
    start < shortlist.length && groupEntries.length < wantedGroups;
    start += chunk
  ) {
    final ids = shortlist.sublist(
      start,
      (start + chunk).clamp(0, shortlist.length),
    );
    for (final DictionaryEntry entry
        in database.dictionaryEntrys
            .getAllSync(ids)
            .whereType<DictionaryEntry>()) {
      final key = '${entry.term}\u0001${entry.reading}';
      if (!groupEntries.containsKey(key) &&
          groupEntries.length >= wantedGroups) {
        continue;
      }
      groupEntries.putIfAbsent(key, () => []).add(entry);
      final s = scores[entry.id]!;
      final previous = groupScore[key];
      if (previous == null || compareScore(s, previous) < 0) {
        groupScore[key] = s;
      }
    }
  }

  // One batched query for every headword's frequency rows.
  final terms = groupEntries.values.map((e) => e.first.term).toSet().toList();
  final frequencyRows = database.dictionaryFrequencys
      .where()
      .anyOf<String, String>(terms, (q, term) => q.termEqualTo(term))
      .findAllSync();
  final frequencies = <String, double>{};
  for (final key in groupEntries.keys) {
    final e = groupEntries[key]!.first;
    double best = double.infinity;
    for (final f in frequencyRows) {
      if (f.term == e.term &&
          (f.reading == e.reading || f.reading.isEmpty) &&
          f.value < best) {
        best = f.value;
      }
    }
    frequencies[key] = best;
  }
  double popularity(String key) =>
      groupEntries[key]!.fold<double>(0, (sum, e) => sum + e.popularity);

  final keys = groupEntries.keys.toList()
    ..sort((a, b) {
      final cmp = compareScore(groupScore[a]!, groupScore[b]!);
      if (cmp != 0) return cmp;
      final fa = frequencies[a]!;
      final fb = frequencies[b]!;
      if (fa != fb) return fa.compareTo(fb);
      return popularity(b).compareTo(popularity(a));
    });

  final builder = SearchResultBuilder(searchTerm: query, maxGroups: maxGroups);
  for (final key in keys) {
    builder.addEntries(groupEntries[key]!);
  }
  // Only entries whose English matched were collected, so 犬 arrived with
  // Jitendex alone. Bring in every enabled dictionary's entries for each
  // shown headword, as a Japanese search for it would.
  final Set<int> shownDictionaries = enabledDictionaryIds.toSet();
  for (final key in keys.take(maxGroups)) {
    final first = groupEntries[key]!.first;
    builder.addEntries(
      database.dictionaryEntrys
          .where()
          .termEqualTo(first.term)
          .findAllSync()
          .where(
            (e) =>
                e.reading == first.reading &&
                (shownDictionaries.isEmpty ||
                    shownDictionaries.contains(e.dictionaryId)),
          ),
    );
  }
  builder.recordMatchLength(query.length);
  return builder.buildFromOrderedGroups(database, builder.rawGroups());
}

/// The Japanese-term search proper: romaji is converted to kana, then
/// exact, deinflected, wildcard and prefix matches are collected.
Future<SearchResultData?> _prepareSearchResultsJapaneseTerms(
  DictionarySearchParams params,
) async {
  const kanaKit = KanaKit();

  String searchTerm = params.searchTerm.trim();
  if (kanaKit.isRomaji(searchTerm)) {
    searchTerm = kanaKit.toHiragana(searchTerm);
  }
  if (searchTerm.length > 20) {
    searchTerm = searchTerm.substring(0, 20);
  }
  if (searchTerm.isEmpty) return null;

  // Reuse the isolate's existing Isar handle if one is already
  // cached (persistent-worker isolate, second and subsequent calls).
  // See the same note in standard_searches.dart.
  final database =
      Isar.getInstance() ??
      await Isar.open(
        globalSchemas,
        directory: params.directoryPath,
        maxSizeMiB: 8192,
      );

  // Only dictionaries used for this language and not hidden for it: a
  // hidden or foreign dictionary's hits used to take up the result budget
  // and then be dropped at display.
  final List<int> scope = params.enabledDictionaryIds;
  if (scope.isEmpty) return null;

  final maxGroups = params.maximumDictionaryTermsInResult;
  final builder = SearchResultBuilder(
    searchTerm: searchTerm,
    maxGroups: maxGroups,
  );

  int entryFetchLimit() {
    final remaining = builder.remainingGroups();
    if (remaining <= 0) return 0;
    return remaining * 8;
  }

  final shouldSearchWildcards =
      params.searchWithWildcards &&
      (searchTerm.contains('\u203B') ||
          searchTerm.contains('\uFF1F') ||
          searchTerm.contains('*') ||
          searchTerm.contains('?'));

  if (shouldSearchWildcards) {
    final noExactMatches = database.dictionaryEntrys
        .where()
        .termEqualTo(searchTerm)
        .isEmptySync();

    if (noExactMatches) {
      final matchesTerm = searchTerm
          .replaceAll('\u203B', '*')
          .replaceAll('\uFF1F', '?')
          .replaceAll('?', '???');

      final withoutWildcards = matchesTerm
          .replaceAll('?', '')
          .replaceAll('*', '');
      final matchTermIsKana = kanaKit.isKana(withoutWildcards);
      final matchTermIsKatakana = kanaKit.isKatakana(withoutWildcards);

      final questionMarkOnly = !matchesTerm.contains('*');
      final noAsterisks = searchTerm
          .replaceAll('\u203B', '*')
          .replaceAll('\uFF1F', '?')
          .replaceAll('*', '');

      final lim = entryFetchLimit();
      if (lim > 0) {
        List<DictionaryEntry> entries;
        if (questionMarkOnly) {
          entries = database.dictionaryEntrys
              .where()
              .termLengthEqualTo(searchTerm.length)
              .filter()
              .termMatches(matchesTerm, caseSensitive: false)
              .and()
              .anyOf<int, int>(scope, (q, id) => q.dictionaryIdEqualTo(id))
              .limit(lim)
              .findAllSync();
        } else {
          entries = database.dictionaryEntrys
              .where()
              .termLengthGreaterThan(noAsterisks.length, include: true)
              .filter()
              .termMatches(matchesTerm, caseSensitive: false)
              .and()
              .anyOf<int, int>(scope, (q, id) => q.dictionaryIdEqualTo(id))
              .limit(lim)
              .findAllSync();
        }
        builder.addEntries(entries);
        if (entries.isNotEmpty) builder.recordMatchLength(searchTerm.length);
      }

      if (matchTermIsKana && entryFetchLimit() > 0) {
        final readingEntries = database.dictionaryEntrys
            .where()
            .filter()
            .group(
              (q) => q
                  .readingMatches(matchesTerm)
                  .or()
                  .optional(
                    matchTermIsKatakana,
                    (q) => q.readingMatches(kanaKit.toHiragana(matchesTerm)),
                  ),
            )
            .and()
            .anyOf<int, int>(scope, (q, id) => q.dictionaryIdEqualTo(id))
            .limit(entryFetchLimit())
            .findAllSync();
        builder.addEntries(readingEntries);
        if (readingEntries.isNotEmpty) {
          builder.recordMatchLength(searchTerm.length);
        }
      }
    }
  } else {
    final deinflectionsAlreadySearched = <String>{};
    bool startsWithAdded = false;

    for (int i = 0; i < searchTerm.length; i++) {
      final partialTerm = searchTerm.substring(0, searchTerm.length - i);
      final partialTermIsKana = kanaKit.isKana(partialTerm);
      final partialTermIsHiragana = kanaKit.isHiragana(partialTerm);
      final partialTermIsKatakana = kanaKit.isKatakana(partialTerm);

      final possibleDeinflections = JapaneseTransformer.instance
          .dictionaryForms(partialTerm)
          .where((e) => !deinflectionsAlreadySearched.contains(e))
          .toList();
      deinflectionsAlreadySearched.addAll(possibleDeinflections);

      // termExact (+ optional katakana→hiragana fallback).
      List<DictionaryEntry> termExact = const <DictionaryEntry>[];
      if (entryFetchLimit() > 0) {
        try {
          termExact = database.dictionaryEntrys
              .where()
              .termEqualTo(partialTerm)
              .or()
              .optional(
                partialTermIsKatakana,
                (q) => q.termEqualTo(kanaKit.toHiragana(partialTerm)),
              )
              .filter()
              .anyOf<int, int>(scope, (q, id) => q.dictionaryIdEqualTo(id))
              .limit(entryFetchLimit())
              .findAllSync();
        } catch (_) {
          // If Isar chokes on a query for this partial, skip the whole
          // iteration (same behaviour as original).
          continue;
        }
        builder.addEntries(termExact);
      }

      // readingExact (only for kana inputs).
      List<DictionaryEntry> readingExact = const <DictionaryEntry>[];
      if (partialTermIsKana && entryFetchLimit() > 0) {
        readingExact = database.dictionaryEntrys
            .where()
            .readingEqualTo(partialTerm)
            .or()
            .optional(
              partialTermIsKatakana,
              (q) => q.readingEqualTo(kanaKit.toHiragana(partialTerm)),
            )
            .filter()
            .anyOf<int, int>(scope, (q, id) => q.dictionaryIdEqualTo(id))
            .limit(entryFetchLimit())
            .findAllSync();
        builder.addEntries(readingExact);
      }

      // termDeinflected.
      List<DictionaryEntry> termDeinflected = const <DictionaryEntry>[];
      if (possibleDeinflections.isNotEmpty && entryFetchLimit() > 0) {
        termDeinflected = database.dictionaryEntrys
            .where()
            .anyOf<String, String>(
              possibleDeinflections,
              (q, term) => q.termEqualTo(term),
            )
            .or()
            .optional(
              partialTermIsKatakana,
              (q) => q.anyOf<String, String>(
                JapaneseTransformer.instance.dictionaryForms(
                  kanaKit.toHiragana(partialTerm),
                ),
                (q, term) => q.termEqualTo(term),
              ),
            )
            .filter()
            .anyOf<int, int>(scope, (q, id) => q.dictionaryIdEqualTo(id))
            .limit(entryFetchLimit())
            .findAllSync();
        // Sort by popularity so more common lemmas win in the insertion
        // order when there are ties later.
        termDeinflected.sort((a, b) => b.popularity.compareTo(a.popularity));
        builder.addEntries(termDeinflected);
      }

      // readingDeinflected (kana only).
      List<DictionaryEntry> readingDeinflected = const <DictionaryEntry>[];
      if (partialTermIsKana &&
          possibleDeinflections.isNotEmpty &&
          entryFetchLimit() > 0) {
        readingDeinflected = database.dictionaryEntrys
            .where()
            .anyOf<String, String>(
              possibleDeinflections,
              (q, reading) => q.readingEqualTo(reading),
            )
            .or()
            .optional(
              partialTermIsKatakana,
              (q) => q.anyOf<String, String>(
                JapaneseTransformer.instance.dictionaryForms(
                  kanaKit.toHiragana(partialTerm),
                ),
                (q, term) => q.readingEqualTo(term),
              ),
            )
            .filter()
            .anyOf<int, int>(scope, (q, id) => q.dictionaryIdEqualTo(id))
            .limit(entryFetchLimit())
            .findAllSync();
        builder.addEntries(readingDeinflected);
      }

      // termExactKatakana (hiragana → katakana fallback).
      List<DictionaryEntry> termExactKatakana = const <DictionaryEntry>[];
      if (partialTermIsHiragana && entryFetchLimit() > 0) {
        termExactKatakana = database.dictionaryEntrys
            .where()
            .termEqualTo(kanaKit.toKatakana(partialTerm))
            .filter()
            .anyOf<int, int>(scope, (q, id) => q.dictionaryIdEqualTo(id))
            .limit(entryFetchLimit())
            .findAllSync();
        builder.addEntries(termExactKatakana);
      }

      if ((termExact.isNotEmpty ||
              readingExact.isNotEmpty ||
              termDeinflected.isNotEmpty ||
              readingDeinflected.isNotEmpty ||
              termExactKatakana.isNotEmpty) &&
          builder.bestLength < partialTerm.length) {
        builder.recordMatchLength(partialTerm.length);
      }

      // startsWith fallback, conditional on mode.
      if (entryFetchLimit() > 0) {
        final shouldAddStartsWith = params.searchWithWildcards
            ? (i == 0)
            : (!startsWithAdded && builder.groupCount > 0);

        if (shouldAddStartsWith) {
          startsWithAdded = true;
          final startsWith = database.dictionaryEntrys
              .where()
              .termStartsWith(searchTerm)
              .filter()
              .anyOf<int, int>(scope, (q, id) => q.dictionaryIdEqualTo(id))
              .sortByTermLength()
              .limit(entryFetchLimit())
              .findAllSync();
          builder.addEntries(startsWith);
        }
      }
    }
  }

  // Extract raw group accumulators for the custom post-sort.
  final rawGroups = builder.rawGroups();
  if (rawGroups.isEmpty) return null;

  // Load every entry across every group in one batched DB call.
  final allEntryIds = <int>[];
  for (final g in rawGroups) {
    allEntryIds.addAll(g.entryIds);
  }
  final entriesById = <int, DictionaryEntry>{
    for (final e
        in database.dictionaryEntrys
            .getAllSync(allEntryIds)
            .whereType<DictionaryEntry>())
      e.id!: e,
  };

  // Load dictionaries once; used by the frequency-by-dictionary-order
  // sort below. The `order` field controls the user's preferred display
  // ordering across dictionaries.
  final dictionaries = database.dictionarys.where().findAllSync();

  // Resolve frequency rows per group. Keyed by group index for cheap
  // lookup during the comparator. Grouped by dictionary-id so we can
  // compare per dictionary.
  final frequenciesByGroupIndex = <int, Map<int, double>>{};
  for (int idx = 0; idx < rawGroups.length; idx++) {
    final g = rawGroups[idx];
    final freqs = database.dictionaryFrequencys
        .where()
        .termEqualTo(g.term)
        .findAllSync()
        .where((f) => f.reading == g.reading || f.reading.isEmpty)
        .toList();
    final perDict = <int, double>{};
    for (final f in freqs) {
      // Keep the minimum (= "most common") value per dictionary, matching
      // the original logic (`.map((e) => e.value).min`).
      final existing = perDict[f.dictionaryId];
      if (existing == null || f.value < existing) {
        perDict[f.dictionaryId] = f.value;
      }
    }
    frequenciesByGroupIndex[idx] = perDict;
  }

  // Resolve 'P' tag presence per group from the stored *TagsRaw strings.
  // In the old schema 'P' was a tag row on the heading; in the flat
  // schema it's a space-separated token on the owning entry. A group is
  // "popular" if any of its entries carries the 'P' token.
  bool groupHasPopularTag(BuilderGroupData g) {
    for (final id in g.entryIds) {
      final entry = entriesById[id];
      if (entry == null) continue;
      final combined = '${entry.entryTagsRaw} ${entry.headingTagsRaw}';
      for (final t in combined.split(' ')) {
        if (t == 'P') return true;
      }
    }
    return false;
  }

  // Precompute per-group sort keys indexed by position in rawGroups. We
  // need these for the comparator.
  final hasPopular = <int, bool>{};
  for (int i = 0; i < rawGroups.length; i++) {
    hasPopular[i] = groupHasPopularTag(rawGroups[i]);
  }

  // Stable map from group object identity → its index in rawGroups.
  final originalIndex = <BuilderGroupData, int>{
    for (int i = 0; i < rawGroups.length; i++) rawGroups[i]: i,
  };

  // Japanese sort. Only two groups that share a term or share a non-
  // empty reading are compared in detail; otherwise insertion order
  // wins. This mirrors the original behaviour and is not a total order.
  int compareGroups(BuilderGroupData a, BuilderGroupData b) {
    final termsEqual = a.term == b.term;
    final readingsEqual =
        a.reading.isNotEmpty && b.reading.isNotEmpty && a.reading == b.reading;

    if (termsEqual || readingsEqual) {
      final aIdx = originalIndex[a]!;
      final bIdx = originalIndex[b]!;

      final aPop = hasPopular[aIdx]! ? -1 : 1;
      final bPop = hasPopular[bIdx]! ? -1 : 1;
      if (aPop != bPop) return aPop.compareTo(bPop);

      // When terms differ (but readings match), fall back to popularity
      // sum first.
      if (!termsEqual) {
        final popCmp = b.popularitySum.compareTo(a.popularitySum);
        if (popCmp != 0) return popCmp;
      }

      final aFreq = frequenciesByGroupIndex[aIdx]!;
      final bFreq = frequenciesByGroupIndex[bIdx]!;

      if (aFreq.isNotEmpty || bFreq.isNotEmpty) {
        // Prefer a group that has a frequency entry from the earliest-
        // ordered dictionary. This matches Yomichan's "dictionary
        // precedence" sorting.
        for (final d in dictionaries) {
          final aHas = aFreq[d.id];
          final bHas = bFreq[d.id];
          if (aHas == null && bHas != null) return 1;
          if (aHas != null && bHas == null) return -1;
        }
        // Both groups have frequency for some shared dictionaries —
        // compare values within each shared dictionary in dict order.
        final shared = aFreq.keys.toSet().intersection(bFreq.keys.toSet());
        if (shared.isNotEmpty) {
          for (final d in dictionaries) {
            if (!shared.contains(d.id)) continue;
            final cmp = aFreq[d.id]!.compareTo(bFreq[d.id]!);
            if (cmp != 0) return cmp;
          }
        }
      } else {
        final popCmp = b.popularitySum.compareTo(a.popularitySum);
        if (popCmp != 0) return popCmp;
      }

      // Tie-break: more entries first.
      final entriesCmp = b.entryIds.length.compareTo(a.entryIds.length);
      if (entriesCmp != 0) return entriesCmp;
    }

    // Fallback: insertion order.
    return a.insertionOrder.compareTo(b.insertionOrder);
  }

  final sortedGroups = rawGroups.toList()..sort(compareGroups);

  // Single-kanji prioritisation: if the user typed exactly one kanji,
  // the group keyed by (searchTerm, '') moves to the front regardless
  // of popularity.
  if (searchTerm.length == 1 && kanaKit.isKanji(searchTerm)) {
    final kanjiGroupIdx = sortedGroups.indexWhere(
      (g) => g.term == searchTerm && g.reading.isEmpty,
    );
    if (kanjiGroupIdx > 0) {
      final g = sortedGroups.removeAt(kanjiGroupIdx);
      sortedGroups.insert(0, g);
    }
  }

  return builder.buildFromOrderedGroups(database, sortedGroups);
}
