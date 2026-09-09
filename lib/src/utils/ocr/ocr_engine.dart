import 'package:flutter/services.dart';

/// One recognised line of text within an [OcrBlock].
class OcrLine {
  /// Initialise a line.
  OcrLine({
    required this.text,
    required this.rect,
  });

  /// The recognised text of the line.
  final String text;

  /// Bounding box of the line in image coordinates.
  final Rect rect;
}

/// One block of recognised text — roughly a paragraph or text box.
class OcrBlock {
  /// Initialise a block. [isVertical] is supplied by the engine, which
  /// decides orientation by a vote across the whole block; the aspect
  /// heuristic is only the fallback when it says nothing.
  OcrBlock({
    required this.text,
    required this.rect,
    required this.lines,
    bool? isVertical,
  }) : isVertical = isVertical ?? (rect.height > rect.width * 1.5);

  /// The recognised text of the whole block.
  final String text;

  /// Bounding box of the block in image coordinates.
  final Rect rect;

  /// The lines making up the block.
  final List<OcrLine> lines;

  /// Whether the block is vertically set (tategaki). Used for
  /// reading-order sorting and for the `writing-mode` styling of
  /// generated overlays.
  ///
  /// Not an aspect test on this rectangle: a bubble of four short
  /// columns is wider than it is tall, yet still tategaki. The engine
  /// votes across the block's own lines instead.
  final bool isVertical;
}

/// The result of recognising one image.
class OcrResult {
  /// Initialise a result.
  OcrResult({
    required this.text,
    required this.blocks,
  });

  /// All recognised text, blocks joined by newlines. Empty if nothing
  /// was recognised.
  final String text;

  /// The recognised blocks with geometry.
  final List<OcrBlock> blocks;
}

/// The pluggable OCR seam. All in-app OCR (subtitle bitmaps, scanned PDF
/// pages, the home-menu smoke test) goes through this interface so the
/// backing engine can be swapped — PP-OCRv6 today, potentially MangaOCR
/// (a manga-specialised recogniser behind the same detector) later,
/// without touching the pipelines that consume it.
abstract class OcrEngine {
  /// Recognise text in an image file on disk (any format the engine's
  /// platform decoder accepts — JPEG/PNG/WebP/BMP).
  Future<OcrResult> recognizeFile(String path);

  /// Recognise text in a raw RGBA bitmap (the `ui.Image.toByteData
  /// (rawRgba)` layout: width * height * 4 bytes). Used by the subtitle
  /// pipeline, whose decoded PGS/VobSub bitmaps never touch disk.
  Future<OcrResult> recognizeBitmap({
    required Uint8List rgba,
    required int width,
    required int height,
  });

  /// Release engine resources. The engine must not be used afterwards.
  Future<void> dispose();
}

/// [OcrEngine] backed by PP-OCRv6 (small tier) running on-device under
/// ONNX Runtime, via the `shiroikuma.jisho/ocr` channel. The models,
/// the detection/recognition pipeline and the tategaki handling all
/// live in `OcrBridge.java`; this is only the seam.
///
/// This replaced Google ML Kit in 1.5.0+028. ML Kit was the app's sole
/// tracker — it merged `MlKitInitProvider` and
/// `MlKitComponentDiscoveryService` into the manifest, both of which
/// start themselves at process launch. PP-OCRv6 is Apache-2.0 for code
/// and weights alike and registers no manifest components.
///
/// The native side holds one detector and one recogniser session open
/// for the engine's lifetime — batch users (subtitle OCR, PDF import)
/// create one engine, feed it every image, then [dispose].
class PpOcrEngine implements OcrEngine {
  /// Initialise an engine. [maxSide] caps the long edge of the
  /// detector's input; 960 is PaddleOCR's default and measured best
  /// here (a 1400x2000 tategaki page scored 1.3% CER at 960 and no
  /// better at 1280 or 1600, for half the time).
  PpOcrEngine({this.maxSide = 960});

  /// Long-edge cap in pixels for the detector's input.
  final int maxSide;

  static const MethodChannel _channel = MethodChannel('shiroikuma.jisho/ocr');

  @override
  Future<OcrResult> recognizeFile(String path) async {
    return _toResult(await _channel.invokeMapMethod<String, dynamic>(
      'recognizeFile',
      {'path': path, 'maxSide': maxSide},
    ));
  }

  @override
  Future<OcrResult> recognizeBitmap({
    required Uint8List rgba,
    required int width,
    required int height,
  }) async {
    return _toResult(await _channel.invokeMapMethod<String, dynamic>(
      'recognizeBitmap',
      {
        'rgba': rgba,
        'width': width,
        'height': height,
        'maxSide': maxSide,
      },
    ));
  }

  @override
  Future<void> dispose() => _channel.invokeMethod<void>('dispose');

  OcrResult _toResult(Map<String, dynamic>? payload) {
    if (payload == null) {
      return OcrResult(text: '', blocks: const []);
    }
    final blocks = <OcrBlock>[];
    for (final raw in (payload['blocks'] as List? ?? const [])) {
      final block = Map<String, dynamic>.from(raw as Map);
      final lines = <OcrLine>[];
      for (final rawLine in (block['lines'] as List? ?? const [])) {
        final line = Map<String, dynamic>.from(rawLine as Map);
        lines.add(
          OcrLine(
            text: line['text'] as String? ?? '',
            rect: _rectOf(line),
          ),
        );
      }
      blocks.add(
        OcrBlock(
          text: block['text'] as String? ?? '',
          rect: _rectOf(block),
          lines: lines,
          isVertical: block['vertical'] as bool?,
        ),
      );
    }
    return OcrResult(
      text: payload['text'] as String? ?? '',
      blocks: blocks,
    );
  }

  static Rect _rectOf(Map<String, dynamic> map) {
    return Rect.fromLTRB(
      (map['l'] as num? ?? 0).toDouble(),
      (map['t'] as num? ?? 0).toDouble(),
      (map['r'] as num? ?? 0).toDouble(),
      (map['b'] as num? ?? 0).toDouble(),
    );
  }
}
