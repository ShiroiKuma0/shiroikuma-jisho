import 'package:expandable/expandable.dart';
import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:spaces/spaces.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shiroikumanojisho/creator.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/pages.dart';
import 'package:shiroikumanojisho/src/models/app_model.dart';
import 'package:shiroikumanojisho/src/models/creator_model.dart';
import 'package:shiroikumanojisho/utils.dart';
import 'package:collection/collection.dart';

/// Returns the widget for a list of [DictionaryEntry] making up a term.
class DictionaryTermPage extends ConsumerWidget {
  /// Create the widget for a dictionary word.
  const DictionaryTermPage({
    required this.heading,
    required this.onSearch,
    required this.onStash,
    required this.onShare,
    required this.expandableControllers,
    required this.dictionaryNamesByHidden,
    required this.dictionaryNamesByOrder,
    required this.lastSelectedMapping,
    this.cardColor,
    this.opacity = 1,
    this.footerWidget,
    super.key,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Action to be done upon selecting the share option.
  final Function(String) onShare;

  /// Controls expandables by dictionary name.
  final Map<Dictionary, ExpandableController> expandableControllers;

  /// Lists whether a dictionary is hidden.
  final Map<String, bool> dictionaryNamesByHidden;

  /// Lists the order of dictionaries.
  final Map<String, int> dictionaryNamesByOrder;

  /// Optional footer foor use in [DictionaryHistoryPage].
  final Widget? footerWidget;

  /// Override color for card background color.
  final Color? cardColor;

  /// Opacity for entries.
  final double opacity;

  /// Last selected mapping for optimisation purposes. Not including this
  /// before caused rendering jank as database queries were performed multiple
  /// times for getting this value.
  final AnkiMapping lastSelectedMapping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);

    List<DictionaryEntry> entries = heading.entries
        .where(
          (entry) => !dictionaryNamesByHidden[entry.dictionary.value!.name]!,
        )
        .toList();

    entries.sort(
      (a, b) => dictionaryNamesByOrder[a.dictionary.value!.name]!.compareTo(
        dictionaryNamesByOrder[b.dictionary.value!.name]!,
      ),
    );

    if (entries.isEmpty) {
      return const SliverPadding(padding: EdgeInsets.zero);
    }

    return SliverStack(
      children: [
        SliverPositioned.fill(
          child: Card(
            color:
                cardColor?.withValues(alpha: opacity) ??
                (appModel.isDarkMode
                    ? Color.fromRGBO(16, 16, 16, opacity)
                    : Color.fromRGBO(249, 249, 249, opacity)),
            elevation: 0,
            shape: const RoundedRectangleBorder(),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            left: Spacing.of(context).spaces.normal,
            top: Spacing.of(context).spaces.small,
            right: Spacing.of(context).spaces.small,
            bottom: Spacing.of(context).spaces.small,
          ),
          sliver: MultiSliver(
            children: [
              // One line: headword, reading with its pitch, markers; the
              // quick actions float at its end.
              SliverToBoxAdapter(
                child: _DictionaryTermTopRow(
                  heading: heading,
                  onSearch: onSearch,
                  dictionaryNamesByHidden: dictionaryNamesByHidden,
                ),
              ),
              // Each kanji of the headword with its first meaning, opening
              // the kanji page.
              SliverToBoxAdapter(
                child: KanjiBreakdown(term: heading.term, onSearch: onSearch),
              ),
              // One chip per dictionary; only the selected dictionary's
              // definitions are shown.
              SliverToBoxAdapter(
                child: _DictionaryTabs(
                  heading: heading,
                  entries: entries,
                  onSearch: onSearch,
                  onStash: onStash,
                  onShare: onShare,
                ),
              ),
              if (footerWidget != null) SliverToBoxAdapter(child: footerWidget),
            ],
          ),
        ),
      ],
    );
  }
}

/// The dictionary shown in a result card, by name; null until the user
/// picks one, when the first expanded dictionary in their order is shown.
final selectedDictionaryProvider =
    StateProvider.family<String?, DictionaryHeading>((ref, heading) => null);

/// A dictionary name short enough for a chip: release dates in brackets
/// and edition notes in parentheses are dropped ("Jitendex.org
/// [2026-10-03]" → "Jitendex.org").
String shortDictionaryName(String name) {
  String short = name
      .replaceAll(RegExp(r'\s*[\[［(（【].*?[\]］)）】]\s*'), ' ')
      .replaceAll(RegExp(r'[\s　]+'), ' ')
      .trim();
  if (short.isEmpty) short = name;
  return short.length > 16 ? '${short.substring(0, 15)}…' : short;
}

class _DictionaryTabs extends ConsumerWidget {
  const _DictionaryTabs({
    required this.heading,
    required this.entries,
    required this.onSearch,
    required this.onStash,
    required this.onShare,
  });

  final DictionaryHeading heading;

  /// Visible entries, already in the user's dictionary order.
  final List<DictionaryEntry> entries;
  final Function(String) onSearch;
  final Function(String) onStash;
  final Function(String) onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);
    final Color color = Color(appModel.dictionaryFontColor);

    final Map<String, List<DictionaryEntry>> byDictionary = {};
    final Map<String, Dictionary> dictionaries = {};
    for (final entry in entries) {
      final dictionary = entry.dictionary.value!;
      byDictionary.putIfAbsent(dictionary.name, () => []).add(entry);
      dictionaries[dictionary.name] = dictionary;
    }

    String? selected = ref.watch(selectedDictionaryProvider(heading));
    if (selected == null || !byDictionary.containsKey(selected)) {
      selected =
          dictionaries.values
              .firstWhereOrNull((d) => !d.isCollapsed(appModel.targetLanguage))
              ?.name ??
          byDictionary.keys.first;
    }

    final chips = byDictionary.keys.map((name) {
      final bool isSelected = name == selected;
      return GestureDetector(
        onTap: () =>
            ref.read(selectedDictionaryProvider(heading).notifier).state = name,
        onLongPressStart: (details) => _showDictionaryMenu(
          context: context,
          ref: ref,
          position: details.globalPosition,
          dictionary: dictionaries[name]!,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            border: Border.all(color: color.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            shortDictionaryName(name),
            style: TextStyle(
              fontSize: appModel.dictionaryFontSize * 0.62,
              color: isSelected ? Colors.black : color.withValues(alpha: 0.8),
            ),
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: Spacing.of(context).spaces.extraSmall,
          ),
          // The selected dictionary's own entry tags (★, priority form…)
          // ride on the chip row instead of taking a row of their own.
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...chips,
              for (final tag in {
                for (final e in byDictionary[selected]!) ...e.tags,
              })
                JidoujishoTag(
                  text: tag.name,
                  message: tag.notes,
                  backgroundColor: tag.color,
                ),
            ],
          ),
        ),
        ...byDictionary[selected]!.map(
          (entry) => DictionaryEntryPage(
            key: ValueKey(entry.id),
            entry: entry,
            heading: heading,
            onSearch: onSearch,
            onStash: onStash,
            onShare: onShare,
            compact: true,
            showTags: false,
          ),
        ),
      ],
    );
  }

  /// The single-dictionary quick actions (send this dictionary's meaning
  /// to Anki, …), formerly on the dictionary name tag's ⋮ menu.
  Future<void> _showDictionaryMenu({
    required BuildContext context,
    required WidgetRef ref,
    required Offset position,
    required Dictionary dictionary,
  }) async {
    AppModel appModel = ref.read(appProvider);
    CreatorModel creatorModel = ref.read(creatorProvider);

    final actions = appModel.lastSelectedMapping
        .getActions(appModel: appModel)
        .where((e) => e.showInSingleDictionary)
        .toList();
    if (actions.isEmpty) return;

    final QuickAction? chosen = await showMenu<QuickAction>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      color: Theme.of(context).popupMenuTheme.color,
      items: actions
          .map(
            (action) => PopupMenuItem<QuickAction>(
              value: action,
              child: Row(
                children: [
                  Icon(
                    action.icon,
                    size: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  ),
                  const Space.normal(),
                  Text(action.getLocalisedLabel(appModel)),
                ],
              ),
            ),
          )
          .toList(),
    );
    if (chosen == null || !context.mounted) return;

    await chosen.executeAction(
      context: context,
      ref: ref,
      appModel: appModel,
      creatorModel: creatorModel,
      heading: heading,
      dictionaryName: dictionary.name,
    );
    ref.invalidate(quickActionColorProvider(heading));
  }
}

class _DictionaryTermActionsRow extends ConsumerStatefulWidget {
  const _DictionaryTermActionsRow({required this.heading});

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DictionaryTermActionsRowState();
}

class _DictionaryTermActionsRowState
    extends ConsumerState<_DictionaryTermActionsRow> {
  VisibilityInfo? visibilityInfo;

  @override
  Widget build(BuildContext context) {
    AppModel appModel = ref.read(appProvider);
    CreatorModel creatorModel = ref.read(creatorProvider);
    bool visibleOnce = ref.watch(visibleOnceProvider(widget.heading));

    Map<String, Color?> defaultColors = Map<String, Color?>.fromEntries(
      appModel.quickActions.values.map((e) => MapEntry(e.uniqueKey, null)),
    );

    if (!visibleOnce) {
      return VisibilityDetector(
        key: UniqueKey(),
        onVisibilityChanged: (info) {
          visibilityInfo = info;
          if (info.visibleFraction > 0) {
            ref.watch(visibleOnceProvider(widget.heading).notifier).state =
                true;
          }
        },
        child: buildRow(
          context: context,
          appModel: appModel,
          creatorModel: creatorModel,
          ref: ref,
          colors: defaultColors,
        ),
      );
    }

    AsyncValue<Map<String, Color?>> colors = ref.watch(
      quickActionColorProvider(widget.heading),
    );

    return colors.when(
      data: (colors) {
        return buildRow(
          context: context,
          appModel: appModel,
          creatorModel: creatorModel,
          ref: ref,
          colors: colors,
        );
      },
      loading: () => buildRow(
        context: context,
        appModel: appModel,
        creatorModel: creatorModel,
        ref: ref,
        colors: defaultColors,
      ),
      error: (_, _) => buildRow(
        context: context,
        appModel: appModel,
        creatorModel: creatorModel,
        ref: ref,
        colors: defaultColors,
      ),
    );
  }

  Widget buildRow({
    required BuildContext context,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required WidgetRef ref,
    required Map<String, Color?> colors,
  }) {
    List<Widget> buttons = [];
    for (int i = 0; i < appModel.maximumQuickActions; i++) {
      String? actionName = appModel.lastSelectedMapping.actions![i];
      QuickAction? quickAction;

      if (actionName != null) {
        quickAction = appModel.quickActions[actionName];
      }
      late Widget button;

      if (quickAction == null) {
        button = const SizedBox.shrink();
      } else {
        late Color enabledColor;
        Color defaultColor = Theme.of(context).brightness == Brightness.dark
            ? Color(appModel.dictionaryFontColor)
            : Colors.black;
        enabledColor = colors[quickAction.uniqueKey] ?? defaultColor;
        button = Padding(
          padding: Spacing.of(context).insets.onlyLeft.semiSmall,
          child: JidoujishoIconButton(
            busy: true,
            enabledColor: enabledColor,
            disabledColor: enabledColor.withValues(alpha: 0.5),
            shapeBorder: const RoundedRectangleBorder(),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Color(appModel.dictionaryFontColor).withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            size: Spacing.of(context).spaces.semiBig,
            tooltip: quickAction.getLocalisedLabel(appModel),
            icon: quickAction.icon,
            onTap: () async {
              await quickAction!.executeAction(
                context: context,
                ref: ref,
                appModel: appModel,
                creatorModel: creatorModel,
                heading: widget.heading,
                dictionaryName: null,
              );

              ref.invalidate(quickActionColorProvider(widget.heading));
            },
          ),
        );
      }

      buttons.add(button);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: buttons.reversed.toList(),
    );
  }
}

class _DictionaryTermTopRow extends ConsumerWidget {
  const _DictionaryTermTopRow({
    required this.heading,
    required this.onSearch,
    required this.dictionaryNamesByHidden,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Lists whether a dictionary is hidden.
  final Map<String, bool> dictionaryNamesByHidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatColumn(
      children: [
        Floatable(
          float: FCFloat.end,
          padding: EdgeInsets.only(
            left: Spacing.of(context).spaces.small,
            bottom: Spacing.of(context).spaces.extraSmall,
          ),
          child: _DictionaryTermActionsRow(heading: heading),
        ),
        _DictionaryTermHeaderLine(
          heading: heading,
          onSearch: onSearch,
          dictionaryNamesByHidden: dictionaryNamesByHidden,
        ),
      ],
    );
  }
}

/// The headword, its reading with the pitch drawn on it, and small muted
/// markers — the heading's own tags (★ etc.) and the top frequency rank —
/// on one wrapping line, instead of a tag row, a frequency row and a pitch
/// row stacked under the headword.
class _DictionaryTermHeaderLine extends ConsumerWidget {
  const _DictionaryTermHeaderLine({
    required this.heading,
    required this.onSearch,
    required this.dictionaryNamesByHidden,
  });

  final DictionaryHeading heading;
  final Function(String) onSearch;
  final Map<String, bool> dictionaryNamesByHidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);
    final Color color = Theme.of(context).brightness == Brightness.dark
        ? Color(appModel.dictionaryFontColor)
        : Colors.black;
    final Color muted = color.withValues(alpha: 0.65);

    bool visible(Dictionary? d) =>
        d != null && !(dictionaryNamesByHidden[d.name] ?? true);

    // Distinct accent patterns across the pitch dictionaries, in order.
    final pitches =
        heading.pitches.where((p) => visible(p.dictionary.value)).toList()
          ..sort(
            (a, b) =>
                a.dictionary.value!.order.compareTo(b.dictionary.value!.order),
          );
    final downsteps = <int>[];
    for (final p in pitches) {
      if (!downsteps.contains(p.downstep)) downsteps.add(p.downstep);
    }

    // The top frequency dictionary's rank, its first figure only
    // ("1462, 33889㋕" → 1462).
    final frequencies =
        [
          ...heading.frequencies,
          ...appModel.getNoReadingFrequencies(heading: heading),
        ].where((f) => visible(f.dictionary.value)).toList()..sort(
          (a, b) =>
              a.dictionary.value!.order.compareTo(b.dictionary.value!.order),
        );
    final DictionaryFrequency? frequency = frequencies.firstOrNull;

    final bool showReading =
        heading.reading.isNotEmpty && heading.reading != heading.term;

    // Other written forms of this word, from the first visible dictionary
    // (in the user's order) that lists them — Jitendex's 犬、狗、イヌ.
    final List<String> otherForms = [];
    final visibleEntries =
        heading.entries.where((e) => visible(e.dictionary.value)).toList()
          ..sort(
            (a, b) =>
                a.dictionary.value!.order.compareTo(b.dictionary.value!.order),
          );
    for (final entry in visibleEntries) {
      final forms = extractWrittenForms(entry.definitions);
      if (forms.isEmpty) continue;
      for (final form in forms) {
        if (form != heading.term && !otherForms.contains(form)) {
          otherForms.add(form);
        }
      }
      break;
    }
    final double readingSize = appModel.dictionaryFontSize;

    Widget marker(String text, {String? tooltip}) {
      final widget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: muted),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: readingSize * 0.55, color: muted),
        ),
      );
      return tooltip == null
          ? widget
          : Tooltip(message: tooltip, child: widget);
    }

    final List<Widget> children = [
      // The headword alone, large; its kanji stay tappable for lookup.
      if (showReading)
        _PlainHeadword(heading: heading, onSearch: onSearch)
      else
        appModel.targetLanguage.getTermReadingOverrideWidget(
          context: context,
          appModel: appModel,
          heading: heading,
          onSearch: onSearch,
        ),
      if (otherForms.isNotEmpty)
        Text(
          '、${otherForms.join('、')}',
          style: TextStyle(fontSize: readingSize * 0.85, color: muted),
        ),
      if (downsteps.isNotEmpty)
        for (final downstep in downsteps.take(2))
          // The pitch widget prints the reading and its [n] itself.
          appModel.targetLanguage.getPitchWidget(
            appModel: appModel,
            context: context,
            reading: heading.reading.isEmpty ? heading.term : heading.reading,
            downstep: downstep,
          )
      else if (showReading)
        Text(
          heading.reading,
          style: TextStyle(fontSize: readingSize, color: muted),
        ),
      // Several dictionaries (or both of a word's entries) can carry the
      // same tag; show each once.
      for (final tag in {
        for (final tag in heading.tags) tag.name: tag,
      }.values)
        marker(tag.name, tooltip: tag.notes),
      if (frequency != null)
        marker(
          '#${frequency.displayValue.split(RegExp(r'[,，、\s]')).first}',
          tooltip: frequency.dictionary.value!.name,
        ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: children,
    );
  }
}

/// The headword without furigana (the reading follows it, with its
/// pitch); tapping a kanji opens its kanji page.
class _PlainHeadword extends ConsumerWidget {
  const _PlainHeadword({required this.heading, required this.onSearch});

  final DictionaryHeading heading;
  final Function(String) onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);
    final style = Theme.of(context).textTheme.titleLarge!.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: appModel.dictionaryHeadingFontSize,
      fontFamily: appModel.dictionaryHeadingFontFamily.isEmpty
          ? null
          : appModel.dictionaryHeadingFontFamily,
      color: Color(appModel.dictionaryFontColor),
      height: 1.1,
    );
    return Text.rich(
      TextSpan(
        children: heading.term.characters.map((c) {
          final int code = c.runes.first;
          final bool kanji = code >= 0x3400 && code <= 0x9FFF;
          return kanji
              ? WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => KanjiPage.open(
                      context,
                      character: c,
                      onSearch: onSearch,
                    ),
                    child: Text(c, style: style),
                  ),
                )
              : TextSpan(text: c, style: style);
        }).toList(),
      ),
    );
  }
}
