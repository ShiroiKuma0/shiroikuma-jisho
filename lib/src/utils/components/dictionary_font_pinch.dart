import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiroikumanojisho/models.dart';

/// Pinch anywhere on [builder]'s content to resize dictionary text: the
/// same persisted sizes the result list's pinch and edge swipe change
/// (entry, heading, translation and furigana, kept in proportion), with
/// the size shown while pinching. Raw pointers through a Listener, so
/// one-finger scrolling and taps never compete with it; [builder] gets
/// `pinching` to switch its scrolling off while two fingers are down.
class DictionaryFontPinch extends ConsumerStatefulWidget {
  /// Wrap [builder]'s content.
  const DictionaryFontPinch({required this.builder, super.key});

  /// Builds the content; `pinching` is true while two fingers are down.
  final Widget Function(BuildContext context, bool pinching) builder;

  @override
  ConsumerState<DictionaryFontPinch> createState() =>
      _DictionaryFontPinchState();
}

class _DictionaryFontPinchState extends ConsumerState<DictionaryFontPinch> {
  static const double _min = 8;
  static const double _max = 60;
  static const Duration _throttle = Duration(milliseconds: 50);

  final Map<int, Offset> _pointers = {};
  double? _startSpan;
  double _startSize = 24;
  double _size = 24;
  double _headingRatio = 28 / 24;
  double _translationRatio = 1;
  double _rubyRatio = 14 / 24;
  DateTime? _lastWrite;
  bool _pinching = false;
  bool _showSize = false;
  Timer? _hide;

  double get _span {
    final p = _pointers.values.toList();
    return (p[0] - p[1]).distance;
  }

  void _begin() {
    final appModel = ref.read(appProvider);
    _startSize = _size = appModel.dictionaryFontSize;
    if (_startSize > 0) {
      _headingRatio = appModel.dictionaryHeadingFontSize / _startSize;
      _translationRatio = appModel.dictionaryTranslationFontSize / _startSize;
      _rubyRatio = appModel.dictionaryHeadingRubyFontSize / _startSize;
    }
  }

  void _write({bool commit = false}) {
    final now = DateTime.now();
    if (!commit &&
        _lastWrite != null &&
        now.difference(_lastWrite!) < _throttle) {
      return;
    }
    final appModel = ref.read(appProvider);
    appModel.setDictionaryFontSize(_size);
    appModel.setDictionaryHeadingFontSize(
      (_size * _headingRatio).clamp(_min, 80),
    );
    appModel.setDictionaryTranslationFontSize(
      (_size * _translationRatio).clamp(_min, _max),
    );
    appModel.setDictionaryHeadingRubyFontSize(
      (_size * _rubyRatio).clamp(6, _max),
    );
    appModel.refresh();
    _lastWrite = commit ? null : now;
  }

  void _down(PointerDownEvent e) {
    _pointers[e.pointer] = e.position;
    if (_pointers.length == 2) {
      _startSpan = _span;
      _begin();
      _hide?.cancel();
      setState(() {
        _pinching = true;
        _showSize = true;
      });
    }
  }

  void _move(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) {
      return;
    }
    _pointers[e.pointer] = e.position;
    final start = _startSpan;
    if (_pointers.length != 2 || start == null || start < 1) {
      return;
    }
    _size = (_startSize * _span / start).clamp(_min, _max);
    _write();
    setState(() {});
  }

  void _up(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_pinching && _pointers.length < 2) {
      _startSpan = null;
      _write(commit: true);
      setState(() => _pinching = false);
      _hide = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showSize = false);
      });
    }
  }

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(ref.watch(appProvider).dictionaryFontColor);
    return Stack(
      children: [
        Listener(
          onPointerDown: _down,
          onPointerMove: _move,
          onPointerUp: _up,
          onPointerCancel: _up,
          child: widget.builder(context, _pinching),
        ),
        if (_showSize)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    border: Border.all(color: color),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _size.round().toString(),
                    style: TextStyle(color: color, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
