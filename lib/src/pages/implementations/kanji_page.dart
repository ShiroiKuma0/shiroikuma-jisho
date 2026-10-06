import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/models.dart';
import 'package:shiroikumanojisho/utils.dart';

/// Everything about one kanji: its readings, meanings and stats from the
/// kanji dictionaries (KANJIDIC), its frequency rank, and the most common
/// words that begin with it. Opened by tapping a kanji in a headword or in
/// a result's kanji breakdown.
class KanjiPage extends ConsumerWidget {
  /// Create the page for [character].
  const KanjiPage({
    required this.character,
    required this.onSearch,
    super.key,
  });

  /// The kanji shown.
  final String character;

  /// Looks a word up (and closes this page first).
  final Function(String) onSearch;

  /// Open the page for [character] over the current screen.
  static Future<void> open(
    BuildContext context, {
    required String character,
    required Function(String) onSearch,
  }) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => KanjiPage(character: character, onSearch: onSearch),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppModel appModel = ref.watch(appProvider);
    final Isar db = appModel.database;
    final Color color = Color(appModel.dictionaryFontColor);
    final Color muted = color.withValues(alpha: 0.65);
    final double size = appModel.dictionaryFontSize;

    final Map<int, Dictionary> dictionaries = {
      for (final d in appModel.dictionaries) d.id: d,
    };
    bool visible(int id) =>
        dictionaries[id] != null &&
        !dictionaries[id]!.isHidden(appModel.targetLanguage);

    final kanji = db.dictionaryKanjis
        .where()
        .characterEqualTo(character)
        .findAllSync()
        .where((k) => visible(k.dictionaryId))
        .toList()
      ..sort((a, b) => dictionaries[a.dictionaryId]!
          .order
          .compareTo(dictionaries[b.dictionaryId]!.order));
    final DictionaryKanji? main = kanji.firstOrNull;

    final frequencies = db.dictionaryFrequencys
        .where()
        .termEqualTo(character)
        .findAllSync()
        .where((f) => f.reading.isEmpty && visible(f.dictionaryId))
        .toList();

    final words = _commonWords(db, visible);

    TextStyle text(double scale, {Color? c, FontWeight? weight}) =>
        TextStyle(fontSize: size * scale, color: c ?? color, fontWeight: weight);

    Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: '$label  ', style: text(0.7, c: muted)),
            TextSpan(text: value, style: text(0.9)),
          ])),
        );

    final stats = <String>[
      if (main?.stat('strokes') != null) '${main!.stat('strokes')} strokes',
      if (main?.stat('grade') != null) 'grade ${main!.stat('grade')}',
      if (main?.stat('jlpt') != null) 'JLPT N${main!.stat('jlpt')}',
      if (main?.stat('freq') != null) 'newspaper #${main!.stat('freq')}',
      for (final f in frequencies)
        '${dictionaries[f.dictionaryId]?.name ?? ''} #${f.displayValue}',
      if (main?.stat('skip') != null) 'SKIP ${main!.stat('skip')}',
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(character),
        actions: [
          IconButton(
            tooltip: t.search,
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pop(context);
              onSearch(character);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(character,
                  style: TextStyle(
                    fontSize: size * 4,
                    height: 1.1,
                    color: color,
                    fontFamily: appModel.dictionaryHeadingFontFamily.isEmpty
                        ? null
                        : appModel.dictionaryHeadingFontFamily,
                  )),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (main == null)
                      Text(t.kanji_page_no_data, style: text(0.75, c: muted))
                    else ...[
                      if (main.meanings.isNotEmpty)
                        Text(main.meanings.join('; '),
                            style: text(1, weight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      if (main.onyomi.isNotEmpty)
                        line('音', main.onyomi.join('、')),
                      if (main.kunyomi.isNotEmpty)
                        line('訓', main.kunyomi.join('、')),
                    ],
                    if (stats.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(stats.join(' · '),
                            style: text(0.65, c: muted)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _StrokeOrderSection(character: character, color: color),
          ),
          if (words.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(t.kanji_page_words(kanji: character),
                  style: text(0.7, c: muted)),
            ),
            for (final (term, reading, gloss) in words)
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onSearch(term);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: term, style: text(1)),
                      if (reading.isNotEmpty && reading != term)
                        TextSpan(text: '  $reading', style: text(0.75, c: muted)),
                      if (gloss.isNotEmpty)
                        TextSpan(text: '  $gloss', style: text(0.75)),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Up to 40 words beginning with the kanji, most frequent first, each
  /// with its first English gloss where the gloss index has one.
  List<(String, String, String)> _commonWords(
      Isar db, bool Function(int) visible) {
    final entries = db.dictionaryEntrys
        .where()
        .termStartsWith(character)
        .limit(600)
        .findAllSync()
        .where((e) => e.term != character && visible(e.dictionaryId))
        .toList();
    if (entries.isEmpty) return const [];

    final Map<String, DictionaryEntry> byWord = {};
    for (final e in entries) {
      byWord.putIfAbsent('${e.term}\u0001${e.reading}', () => e);
    }

    final terms = byWord.values.map((e) => e.term).toSet().toList();
    final Map<String, double> rank = {};
    for (final f in db.dictionaryFrequencys
        .where()
        .anyOf<String, String>(terms, (q, term) => q.termEqualTo(term))
        .findAllSync()) {
      if (!visible(f.dictionaryId)) continue;
      for (final entry in byWord.entries) {
        final e = entry.value;
        if (e.term == f.term && (f.reading.isEmpty || f.reading == e.reading)) {
          final previous = rank[entry.key];
          if (previous == null || f.value < previous) rank[entry.key] = f.value;
        }
      }
    }

    final keys = byWord.keys.toList()
      ..sort((a, b) => (rank[a] ?? double.infinity)
          .compareTo(rank[b] ?? double.infinity));

    final out = <(String, String, String)>[];
    for (final key in keys.take(40)) {
      final e = byWord[key]!;
      String gloss = '';
      final row = db.dictionaryGloss
          .where()
          .entryIdEqualTo(e.id!)
          .findFirstSync();
      if (row != null && row.glosses.isNotEmpty) {
        final g = row.glosses.first;
        gloss = g.substring(g.indexOf('\t') + 1);
      }
      out.add((e.term, e.reading, gloss));
    }
    return out;
  }
}

/// The kanji of a headword with each one's first meaning — 犬 dog ·
/// 小 small · 屋 roof — each opening its [KanjiPage].
class KanjiBreakdown extends ConsumerWidget {
  /// Create the breakdown of [term].
  const KanjiBreakdown({
    required this.term,
    required this.onSearch,
    super.key,
  });

  /// The headword.
  final String term;

  /// Passed on to the kanji page.
  final Function(String) onSearch;

  /// Whether [c] is a CJK ideograph.
  static bool isKanji(String c) {
    final int code = c.runes.first;
    return (code >= 0x4E00 && code <= 0x9FFF) ||
        (code >= 0x3400 && code <= 0x4DBF) ||
        (code >= 0xF900 && code <= 0xFAFF) ||
        code == 0x3005;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppModel appModel = ref.watch(appProvider);
    final characters = <String>[];
    for (final c in term.characters) {
      if (isKanji(c) && c != '々' && !characters.contains(c)) characters.add(c);
    }
    if (characters.isEmpty) return const SizedBox.shrink();

    final Color color = Color(appModel.dictionaryFontColor);
    final double size = appModel.dictionaryFontSize * 0.7;
    final rows = appModel.database.dictionaryKanjis;

    final spans = <Widget>[];
    for (final c in characters) {
      final k = rows.where().characterEqualTo(c).findFirstSync();
      final meaning = k?.meanings.firstOrNull ?? '';
      spans.add(InkWell(
        onTap: () => KanjiPage.open(context, character: c, onSearch: onSearch),
        child: Text.rich(TextSpan(children: [
          TextSpan(
              text: c,
              style: TextStyle(fontSize: size * 1.15, color: color)),
          if (meaning.isNotEmpty)
            TextSpan(
                text: ' $meaning',
                style: TextStyle(
                    fontSize: size, color: color.withValues(alpha: 0.65))),
        ])),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(spacing: 12, runSpacing: 0, children: spans),
    );
  }
}

/// The stroke order of a kanji, or a button to download the KanjiVG data
/// when it is not there yet.
class _StrokeOrderSection extends StatefulWidget {
  const _StrokeOrderSection({required this.character, required this.color});

  final String character;
  final Color color;

  @override
  State<_StrokeOrderSection> createState() => _StrokeOrderSectionState();
}

class _StrokeOrderSectionState extends State<_StrokeOrderSection> {
  final ValueNotifier<String> _progress = ValueNotifier('');
  bool _downloading = false;
  String? _error;
  late Future<(bool, List<String>?)> _load = _read();

  Future<(bool, List<String>?)> _read() async => (
        await KanjiStrokes.isInstalled(),
        await KanjiStrokes.strokesFor(widget.character),
      );

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _error = null;
    });
    try {
      await KanjiStrokes.download(_progress);
    } catch (e) {
      _error = '$e';
    }
    if (!mounted) return;
    setState(() {
      _downloading = false;
      _load = _read();
    });
  }

  @override
  Widget build(BuildContext context) {
    final muted = widget.color.withValues(alpha: 0.65);
    return FutureBuilder<(bool, List<String>?)>(
      future: _load,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        final (installed, strokes) = data;

        if (_downloading) {
          return ValueListenableBuilder<String>(
            valueListenable: _progress,
            builder: (_, value, __) => Text(value, style: TextStyle(color: muted)),
          );
        }
        if (!installed) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.download),
                label: Text(t.kanji_stroke_order_download),
                onPressed: _download,
              ),
              if (_error != null)
                Text(_error!, style: TextStyle(color: muted, fontSize: 12)),
            ],
          );
        }
        if (strokes == null || strokes.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KanjiStrokeOrder(strokes: strokes, color: widget.color),
            const SizedBox(height: 2),
            Text(KanjiStrokes.attribution,
                style: TextStyle(color: muted, fontSize: 9)),
          ],
        );
      },
    );
  }
}
