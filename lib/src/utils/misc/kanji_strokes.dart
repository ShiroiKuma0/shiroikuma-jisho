import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_parsing/path_parsing.dart';
import 'package:path_provider/path_provider.dart';

/// Stroke-order data from KanjiVG (CC BY-SA 3.0, Ulrich Apel and
/// contributors; kanjivg.tagaini.net). Not bundled: downloaded once on
/// request (3.6 MB) and split into one small file per kanji holding its
/// strokes' SVG path data, in stroke order.
class KanjiStrokes {
  KanjiStrokes._();

  /// The KanjiVG release read. Pinned: the release file name carries its
  /// date, so "latest" cannot be addressed directly.
  static const String sourceUrl =
      'https://github.com/KanjiVG/kanjivg/releases/download/r20260714/'
      'kanjivg-20260714.xml.gz';

  /// Attribution KanjiVG's licence asks for.
  static const String attribution =
      'Stroke order: KanjiVG, © Ulrich Apel, CC BY-SA 3.0';

  static Directory? _dir;

  static Future<Directory> _directory() async {
    return _dir ??= Directory(
        path.join((await getApplicationSupportDirectory()).path, 'kanjivg'));
  }

  /// Whether the data has been downloaded.
  static Future<bool> isInstalled() async =>
      File(path.join((await _directory()).path, 'installed')).existsSync();

  /// The strokes of [character] as SVG path data in KanjiVG's 109×109
  /// space, in stroke order; null when unknown or not downloaded.
  static Future<List<String>?> strokesFor(String character) async {
    final hex = character.runes.first.toRadixString(16).padLeft(5, '0');
    final file = File(path.join((await _directory()).path, '$hex.txt'));
    if (!file.existsSync()) return null;
    return file.readAsStringSync().split('\n').where((l) => l.isNotEmpty).toList();
  }

  /// Download and split the data, reporting progress through [progress].
  static Future<void> download(ValueNotifier<String> progress) async {
    progress.value = 'Downloading stroke order data…';
    final response = await http.get(Uri.parse(sourceUrl));
    if (response.statusCode != 200) {
      throw Exception('KanjiVG download failed (HTTP ${response.statusCode})');
    }
    progress.value = 'Preparing stroke order data…';
    final dir = await _directory();
    await compute(_split, (response.bodyBytes, dir.path));
  }

  static void _split((Uint8List, String) args) {
    final (bytes, dirPath) = args;
    final dir = Directory(dirPath);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);

    final xml = utf8.decode(GZipCodec().decode(bytes));
    final kanji =
        RegExp(r'<kanji id="kvg:kanji_([0-9a-f]+)">(.*?)</kanji>', dotAll: true);
    final stroke = RegExp(r'<path [^>]*?\bd="([^"]+)"');
    for (final m in kanji.allMatches(xml)) {
      final strokes = stroke.allMatches(m.group(2)!).map((p) => p.group(1)!);
      File(path.join(dirPath, '${m.group(1)}.txt'))
          .writeAsStringSync(strokes.join('\n'));
    }
    File(path.join(dirPath, 'installed')).writeAsStringSync(sourceUrl);
  }

  /// [d] as a Flutter path in KanjiVG's coordinates.
  static Path toPath(String d) {
    final proxy = _PathProxy();
    writeSvgPathDataToPath(d, proxy);
    return proxy.path;
  }
}

class _PathProxy extends PathProxy {
  final Path path = Path();

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3,
          double y3) =>
      path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}

/// Draws [strokes] (KanjiVG path data) up to [progress] strokes: whole
/// strokes below it, the next one partly, as far as its fraction.
class KanjiStrokePainter extends CustomPainter {
  /// Create a painter.
  KanjiStrokePainter({
    required this.paths,
    required this.progress,
    required this.color,
    required this.ghostColor,
    this.highlightLast = false,
  });

  /// The strokes, in order.
  final List<Path> paths;

  /// Strokes drawn, fractional for the one in progress.
  final double progress;

  /// Ink colour.
  final Color color;

  /// Colour of the strokes not yet drawn, shown faintly.
  final Color ghostColor;

  /// Draw the most recent whole stroke in [ghostColor]'s opposite: used by
  /// the step frames to show which stroke each adds.
  final bool highlightLast;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 109, size.height / 109);
    Paint pen(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final ghost = pen(ghostColor);
    for (final p in paths) {
      canvas.drawPath(p, ghost);
    }

    final ink = pen(color);
    final int whole = progress.floor();
    for (int i = 0; i < whole && i < paths.length; i++) {
      final bool last = highlightLast && i == whole - 1;
      canvas.drawPath(paths[i], last ? pen(const Color(0xFFE53935)) : ink);
    }
    if (whole < paths.length) {
      final double fraction = progress - whole;
      if (fraction > 0) {
        for (final metric in paths[whole].computeMetrics()) {
          canvas.drawPath(
              metric.extractPath(0, metric.length * fraction), ink);
        }
      }
    }
  }

  @override
  bool shouldRepaint(KanjiStrokePainter old) =>
      old.progress != progress || old.paths != paths || old.color != color;
}

/// The kanji drawn stroke by stroke, replayed on tap, with a strip of
/// numbered frames below — one per stroke, the new stroke in red.
class KanjiStrokeOrder extends StatefulWidget {
  /// Create the view for [strokes].
  const KanjiStrokeOrder({
    required this.strokes,
    required this.color,
    this.size = 150,
    super.key,
  });

  /// KanjiVG path data, in stroke order.
  final List<String> strokes;

  /// Ink colour.
  final Color color;

  /// Size of the animated drawing.
  final double size;

  @override
  State<KanjiStrokeOrder> createState() => _KanjiStrokeOrderState();
}

class _KanjiStrokeOrderState extends State<KanjiStrokeOrder>
    with SingleTickerProviderStateMixin {
  late final List<Path> _paths =
      widget.strokes.map(KanjiStrokes.toPath).toList();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 550 * _paths.length),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ghost = widget.color.withValues(alpha: 0.15);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _controller.forward(from: 0),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              size: Size.square(widget.size),
              painter: KanjiStrokePainter(
                paths: _paths,
                progress: _controller.value * _paths.length,
                color: widget.color,
                ghostColor: ghost,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (int i = 1; i <= _paths.length; i++)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ghost),
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size.square(widget.size * 0.3),
                      painter: KanjiStrokePainter(
                        paths: _paths,
                        progress: i.toDouble(),
                        color: widget.color,
                        ghostColor: Colors.transparent,
                        highlightLast: true,
                      ),
                    ),
                    Positioned(
                      left: 2,
                      top: 0,
                      child: Text('$i',
                          style: TextStyle(
                              fontSize: widget.size * 0.06,
                              color: widget.color.withValues(alpha: 0.6))),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
