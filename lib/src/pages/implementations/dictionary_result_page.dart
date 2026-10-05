import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:shiroikumanojisho/creator.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/pages.dart';

/// Returns the widget for a [DictionarySearchResult] which returns a
/// scrollable list of each [DictionaryEntry] in its mappings.
class DictionaryResultPage extends BasePage {
  /// Create the widget of a [DictionarySearchResult].
  const DictionaryResultPage({
    required this.result,
    required this.onSearch,
    required this.onStash,
    required this.onShare,
    this.cardColor,
    this.scrollController,
    this.opacity = 1,
    this.updateHistory = true,
    this.spaceBeforeFirstResult = true,
    this.footerWidget,
    super.key,
  });

  /// The result made from a dictionary database search.
  final DictionarySearchResult result;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Action to be done upon selecting the share option.
  final Function(String) onShare;

  /// Whether or not to update dictionary history upon viewing this result.
  final bool updateHistory;

  /// Whether or not to put a space before the first result.
  final bool spaceBeforeFirstResult;

  /// Override color for the background color for [DictionaryTermPage].
  final Color? cardColor;

  /// Opacity for entries.
  final double opacity;

  /// Allows controlling the scroll position of the page.
  final ScrollController? scrollController;

  /// Optional footer for use for showing more.
  final Widget? footerWidget;

  @override
  BasePageState<DictionaryResultPage> createState() =>
      _DictionaryResultPageState();
}

class _DictionaryResultPageState extends BasePageState<DictionaryResultPage> {
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    _hideIndicatorTimer?.cancel();
    _indicatorVisible.dispose();
    _indicatorSize.dispose();
    super.dispose();
  }

  late ScrollController _scrollController;

  Map<DictionaryHeading, Map<Dictionary, ExpandableController>>
      expandableControllersByHeading = {};

  // Font-size swipe state.
  //
  // The left 15% of the widget's width is a vertical-drag strip
  // that adjusts the dictionary's font size — entry body and
  // heading scaled proportionally, preserving whatever ratio the
  // user has set (defaults to 22:16 ≈ 1.375 but respects any
  // custom ratio established via the Dictionary settings dialog).
  // The ratio is captured once at the start of each drag so the
  // heading:entry relationship stays stable through the swipe.
  //
  // App-wide persistence (setDictionaryFontSize + refresh()) is
  // throttled to ~50 ms because the structured-content rebuild
  // triggered by appModel.refresh() is the main cost path — on a
  // long entry list even 20 fps rebuilds can blow the frame
  // budget, so making the indicator depend on the same rebuild
  // cadence makes the label lag the finger and the user can't
  // hit a specific target size. To decouple, the indicator uses
  // ValueNotifiers that drive tiny ValueListenableBuilder
  // subtrees at the leaves; updating them does not rebuild the
  // dictionary content, only the overlay pill's label and
  // visibility. The structured-content rebuild still runs at the
  // throttled 20 fps so the actual text resize is smooth without
  // janking the UI thread.
  double _gestureEntryFontSize = 24;
  double _gestureRatio = 28.0 / 24.0;

  /// Translation size as a proportion of the entry size, captured at
  /// the start of a drag so the two keep their relationship.
  double _gestureTranslationRatio = 1;
  double _gestureRubyRatio = 14.0 / 24.0;
  final ValueNotifier<bool> _indicatorVisible = ValueNotifier<bool>(false);
  final ValueNotifier<double> _indicatorSize = ValueNotifier<double>(16);
  DateTime? _lastRefreshAt;
  Timer? _hideIndicatorTimer;

  static const double _fontSizeMin = 8;
  static const double _fontSizeMax = 60;
  static const double _headingSizeMax = 80;

  /// Furigana is allowed below [_fontSizeMin] — it is meant to be the
  /// small text, and the settings slider bottoms out at 6 too.
  static const double _rubySizeMin = 6;
  static const Duration _refreshThrottle = Duration(milliseconds: 50);

  /// Capture the starting entry size and the proportions of the other
  /// three sizes to it, so a gesture scales them all together.
  void _beginFontGesture() {
    _gestureEntryFontSize = appModel.dictionaryFontSize;
    _gestureStartEntryFontSize = _gestureEntryFontSize;
    final double headingNow = appModel.dictionaryHeadingFontSize;
    _gestureRatio = _gestureEntryFontSize > 0
        ? headingNow / _gestureEntryFontSize
        : (28.0 / 24.0);
    // Translation glosses have their own size but ride along on
    // the same gesture, keeping whatever proportion to the entry size
    // they were set to — otherwise a swipe would grow the 国語
    // definitions and leave the bilingual ones behind.
    _gestureTranslationRatio = _gestureEntryFontSize > 0
        ? appModel.dictionaryTranslationFontSize / _gestureEntryFontSize
        : 1;
    // Furigana rides along on the same terms. Leaving it out would
    // grow the heading away from the reading printed above it,
    // which is the exact mismatch its own setting exists to fix.
    _gestureRubyRatio = _gestureEntryFontSize > 0
        ? appModel.dictionaryHeadingRubyFontSize / _gestureEntryFontSize
        : (14.0 / 24.0);
  }

  /// Persist [_gestureEntryFontSize] and the sizes derived from it, and
  /// rebuild. Mid-gesture calls are throttled; [commit] always writes.
  void _applyFontGesture({bool commit = false}) {
    // Overlay updates take the fast path — they do not call
    // setState so the dictionary subtree is untouched.
    _indicatorSize.value = _gestureEntryFontSize;
    _indicatorVisible.value = true;

    final DateTime now = DateTime.now();
    if (!commit &&
        _lastRefreshAt != null &&
        now.difference(_lastRefreshAt!) < _refreshThrottle) {
      return;
    }

    appModel.setDictionaryFontSize(_gestureEntryFontSize);
    appModel.setDictionaryHeadingFontSize((_gestureEntryFontSize * _gestureRatio)
        .clamp(_fontSizeMin, _headingSizeMax));
    appModel.setDictionaryTranslationFontSize(
        (_gestureEntryFontSize * _gestureTranslationRatio)
            .clamp(_fontSizeMin, _fontSizeMax));
    appModel.setDictionaryHeadingRubyFontSize(
        (_gestureEntryFontSize * _gestureRubyRatio)
            .clamp(_rubySizeMin, _fontSizeMax));
    appModel.refresh();
    _lastRefreshAt = commit ? null : now;
  }

  void _endFontGesture() {
    // Always commit the final value regardless of throttle so the
    // gesture's last few ticks (if they landed inside the throttle
    // window) aren't lost.
    _applyFontGesture(commit: true);
    _hideIndicatorTimer?.cancel();
    _hideIndicatorTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _indicatorVisible.value = false;
    });
  }

  void _onFontDragUpdate(DragUpdateDetails d) {
    // `_lastRefreshAt` doubles as the first-tick marker: it is null
    // between gestures.
    if (_lastRefreshAt == null) {
      _beginFontGesture();
    }
    final double step = -d.delta.dy / 12;
    _gestureEntryFontSize = (_gestureEntryFontSize + step)
        .clamp(_fontSizeMin, _fontSizeMax);
    _applyFontGesture();
  }

  void _onFontDragEnd(DragEndDetails d) => _endFontGesture();

  // Pinch state. Raw pointers through a Listener rather than a
  // ScaleGestureRecognizer: a recognizer would enter the gesture arena
  // against the scroll view and the expandables, and lose or steal
  // one-finger scrolls. A Listener sees every pointer without competing,
  // and scrolling is switched off only while two fingers are down.
  final Map<int, Offset> _pointers = {};
  double? _pinchStartDistance;
  double _gestureStartEntryFontSize = 24;
  bool _pinching = false;

  double get _pointerSpan {
    final positions = _pointers.values.toList();
    return (positions[0] - positions[1]).distance;
  }

  void _onPointerDown(PointerDownEvent e) {
    _pointers[e.pointer] = e.position;
    if (_pointers.length == 2) {
      _pinchStartDistance = _pointerSpan;
      _beginFontGesture();
      setState(() => _pinching = true);
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) {
      return;
    }
    _pointers[e.pointer] = e.position;
    final double? start = _pinchStartDistance;
    if (_pointers.length != 2 || start == null || start < 1) {
      return;
    }

    _gestureEntryFontSize = (_gestureStartEntryFontSize * _pointerSpan / start)
        .clamp(_fontSizeMin, _fontSizeMax);
    _applyFontGesture();
  }

  void _onPointerUp(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_pinching && _pointers.length < 2) {
      _pinchStartDistance = null;
      _endFontGesture();
      setState(() => _pinching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AnkiMapping lastSelectedMapping = appModel.lastSelectedMapping;

    Map<int, DictionaryHeading> headingsById = Map.fromEntries(
      widget.result.headings.map(
        (heading) => MapEntry(heading.id, heading),
      ),
    );

    List<DictionaryHeading> headings =
        widget.result.headingIds.map((id) => headingsById[id]!).toList();

    List<Dictionary> dictionaries = appModel.dictionaries;
    Map<String, bool> dictionaryNamesByHidden = Map<String, bool>.fromEntries(
        dictionaries
            .map((e) => MapEntry(e.name, e.isHidden(appModel.targetLanguage))));
    Map<String, bool> dictionaryNamesByCollapsed =
        Map<String, bool>.fromEntries(dictionaries.map(
            (e) => MapEntry(e.name, e.isCollapsed(appModel.targetLanguage))));
    Map<String, int> dictionaryNamesByOrder = Map<String, int>.fromEntries(
        dictionaries.map((e) => MapEntry(e.name, e.order)));

    for (DictionaryHeading heading in headings) {
      expandableControllersByHeading.putIfAbsent(heading, () => {});
      for (DictionaryEntry entry in heading.entries) {
        Dictionary dictionary = entry.dictionary.value!;
        expandableControllersByHeading[heading]?.putIfAbsent(
          dictionary,
          () => ExpandableController(
            initialExpanded: !dictionaryNamesByCollapsed[dictionary.name]!,
          ),
        );
      }
    }

    final Widget content = MediaQuery(
      data: MediaQuery.of(context).removePadding(
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
      ),
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: _scrollController,
        child: Padding(
          padding: Spacing.of(context).insets.onlyRight.extraSmall,
          child: CustomScrollView(
            // The ScrollCacheExtent replacement does not exist in 3.44 yet.
      // ignore: deprecated_member_use
      cacheExtent: 999999999999999,
            controller: _scrollController,
            physics: _pinching
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
            slivers: [
              SliverPadding(
                  padding: widget.spaceBeforeFirstResult
                      ? Spacing.of(context).insets.onlyTop.normal
                      : EdgeInsets.zero),
              ...headings
                  .map((heading) => DictionaryTermPage(
                        lastSelectedMapping: lastSelectedMapping,
                        opacity: widget.opacity,
                        cardColor: widget.cardColor,
                        heading: heading,
                        onSearch: widget.onSearch,
                        onStash: widget.onStash,
                        onShare: widget.onShare,
                        expandableControllers:
                            expandableControllersByHeading[heading]!,
                        dictionaryNamesByHidden: dictionaryNamesByHidden,
                        dictionaryNamesByOrder: dictionaryNamesByOrder,
                      ))
                  ,
              if (widget.footerWidget != null) widget.footerWidget!,
            ],
          ),
        ),
      ),
    );

    // Left 15% of the screen width is a vertical-drag strip for
    // font sizing. Matches the reader's edge-gesture ergonomics:
    // screen-width-referenced so the strip is the same physical
    // width whether the dictionary is full-screen on the home tab
    // or in a narrower popup over the reader. `translucent` hit
    // test lets taps and horizontal swipes pass through to the
    // scroll view; only vertical drags are intercepted, and only
    // inside the strip region.
    final double fontStripWidth =
        MediaQuery.of(context).size.width * 0.15;

    return Stack(
      children: [
        // Pinch anywhere on the results to resize them; the size is the
        // same persisted setting the edge swipe and the settings page use.
        Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: content,
        ),
        if (appModel.dictionaryFontSizeSwipeEnabled)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: fontStripWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: _onFontDragUpdate,
              onVerticalDragEnd: _onFontDragEnd,
            ),
          ),
        // Font-size indicator pill. Listens on two notifiers so
        // the finger-tracking label repaints at gesture rate
        // without pulling the dictionary subtree into the
        // rebuild. Centered within the dictionary's local bounds
        // (not the screen) so it stays inside popup bounds when
        // the dictionary is shown in a modal.
        Positioned.fill(
          child: IgnorePointer(
            child: ValueListenableBuilder<bool>(
              valueListenable: _indicatorVisible,
              builder: (context, visible, child) {
                if (!visible) return const SizedBox.shrink();
                return child!;
              },
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.format_size,
                          color: Color(0xFFFFFF00), size: 28),
                      const SizedBox(height: 4),
                      ValueListenableBuilder<double>(
                        valueListenable: _indicatorSize,
                        builder: (context, size, _) {
                          return Text(
                            '${size.round()}px',
                            style: const TextStyle(
                                color: Color(0xFFFFFF00),
                                fontSize: 14),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
