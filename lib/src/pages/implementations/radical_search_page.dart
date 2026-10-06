import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/models.dart';
import 'package:shiroikumanojisho/utils.dart';

/// Find a kanji by its parts: pick radicals, and the kanji containing all
/// of them are listed, fewest strokes first. Radicals that no kanji
/// shares with the current choice are dimmed. Tapping a kanji returns it
/// (the search bar appends it). Data: EDRDG's RADKFILE, bundled.
class RadicalSearchPage extends ConsumerStatefulWidget {
  /// Create the page.
  const RadicalSearchPage({super.key});

  /// Open the page; completes with the chosen kanji, or null.
  static Future<String?> open(BuildContext context) =>
      Navigator.of(context).push<String>(
          MaterialPageRoute(builder: (_) => const RadicalSearchPage()));

  @override
  ConsumerState<RadicalSearchPage> createState() => _RadicalSearchPageState();
}

class _RadicalSearchPageState extends ConsumerState<RadicalSearchPage> {
  /// radical -> (stroke count, kanji containing it)
  static Map<String, (int, Set<String>)>? _radicals;

  final List<String> _selected = [];

  Future<Map<String, (int, Set<String>)>> _load() async {
    if (_radicals != null) return _radicals!;
    final raw = jsonDecode(await rootBundle
        .loadString('assets/language/japanese/radicals/radkfile.json'));
    _radicals = {
      for (final e in (raw as Map<String, dynamic>).entries)
        e.key: (
          (e.value[0] as num).toInt(),
          (e.value[1] as String).characters.toSet(),
        ),
    };
    return _radicals!;
  }

  @override
  Widget build(BuildContext context) {
    final AppModel appModel = ref.watch(appProvider);
    final Color color = Color(appModel.dictionaryFontColor);
    final Color muted = color.withValues(alpha: 0.3);
    final double size = appModel.dictionaryFontSize;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(t.radical_search),
        actions: [
          if (_selected.isNotEmpty)
            IconButton(
              tooltip: t.clear,
              icon: const Icon(Icons.clear),
              onPressed: () => setState(_selected.clear),
            ),
        ],
      ),
      body: FutureBuilder<Map<String, (int, Set<String>)>>(
        future: _load(),
        builder: (context, snapshot) {
          final radicals = snapshot.data;
          if (radicals == null) return const SizedBox.shrink();

          Set<String>? matches;
          for (final r in _selected) {
            final kanji = radicals[r]!.$2;
            matches = matches == null ? {...kanji} : matches.intersection(kanji);
          }

          final candidates = _ordered(appModel.database, matches ?? {});

          final byStrokes = <int, List<String>>{};
          for (final e in radicals.entries) {
            byStrokes.putIfAbsent(e.value.$1, () => []).add(e.key);
          }
          final strokeCounts = byStrokes.keys.toList()..sort();

          return Column(
            children: [
              // The matching kanji, fewest strokes first.
              Container(
                constraints: BoxConstraints(maxHeight: size * 6),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: muted)),
                ),
                child: _selected.isEmpty
                    ? Text(t.radical_search_hint,
                        style: TextStyle(color: color.withValues(alpha: 0.65)))
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            for (final k in candidates)
                              InkWell(
                                onTap: () => Navigator.pop(context, k),
                                child: Text(k,
                                    style: TextStyle(
                                        fontSize: size * 1.4, color: color)),
                              ),
                          ],
                        ),
                      ),
              ),
              // Radicals by stroke count; those that no longer combine
              // with the choice are dimmed.
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final n in strokeCounts) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            color: color.withValues(alpha: 0.25),
                            child: Text('$n',
                                style: TextStyle(
                                    color: color, fontSize: size * 0.6)),
                          ),
                          for (final r in byStrokes[n]!)
                            _radical(
                              r,
                              selected: _selected.contains(r),
                              enabled: matches == null ||
                                  _selected.contains(r) ||
                                  radicals[r]!.$2.any(matches.contains),
                              color: color,
                              muted: muted,
                              size: size,
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _radical(
    String r, {
    required bool selected,
    required bool enabled,
    required Color color,
    required Color muted,
    required double size,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () => setState(() {
                selected ? _selected.remove(r) : _selected.add(r);
              })
          : null,
      child: Container(
        width: size * 1.6,
        height: size * 1.6,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          border: Border.all(color: muted),
        ),
        child: Text(
          r,
          style: TextStyle(
            fontSize: size * 1.05,
            color: selected ? Colors.black : (enabled ? color : muted),
          ),
        ),
      ),
    );
  }

  /// [kanji] ordered by stroke count (from the kanji dictionaries, where
  /// imported), then by frequency rank where known.
  List<String> _ordered(Isar db, Set<String> kanji) {
    if (kanji.isEmpty) return const [];
    final list = kanji.toList();
    final strokes = <String, int>{};
    for (final row in db.dictionaryKanjis
        .where()
        .anyOf<String, String>(list, (q, c) => q.characterEqualTo(c))
        .findAllSync()) {
      final n = int.tryParse(row.stat('strokes') ?? '');
      if (n != null) strokes.putIfAbsent(row.character, () => n);
    }
    list.sort((a, b) {
      final cmp = (strokes[a] ?? 99).compareTo(strokes[b] ?? 99);
      return cmp != 0 ? cmp : a.compareTo(b);
    });
    return list;
  }
}
