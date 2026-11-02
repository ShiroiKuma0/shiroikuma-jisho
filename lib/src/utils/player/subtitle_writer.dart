import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as path;

/// One subtitle stream of a video container, as ffprobe reports it.
class ContainerSubtitleStream {
  /// Describe a stream.
  ContainerSubtitleStream({
    required this.streamIndex,
    required this.ordinal,
    required this.codec,
    required this.tags,
    required this.disposition,
  });

  /// Absolute stream index in the container (`0:N`).
  final int streamIndex;

  /// Position among the subtitle streams (`0:s:N`).
  final int ordinal;

  /// ffprobe codec name — `subrip`, `ass`, `mov_text`, ...
  final String codec;

  /// Stream tags (language, title, ...).
  final Map<String, String> tags;

  /// Disposition flags set on the stream (`default`, `forced`, ...).
  final List<String> disposition;

  /// Whether the track is Advanced SubStation Alpha, which is edited in
  /// its own format so its styling survives the round trip.
  bool get isAss => codec == 'ass' || codec == 'ssa';

  /// The ffmpeg encoder that writes an edited SRT back in this track's
  /// codec, or null for a codec that cannot be written from text
  /// (image-based PGS / VobSub).
  String? get textEncoder {
    switch (codec) {
      case 'subrip':
      case 'srt':
      case 'text':
        return 'srt';
      case 'webvtt':
        return 'webvtt';
      case 'mov_text':
        return 'mov_text';
    }
    return null;
  }
}

/// A cue as written in a subtitle file.
class _Cue {
  _Cue({
    required this.start,
    required this.end,
    required this.text,
  });

  final Duration start;
  final Duration end;
  String text;
  bool removed = false;
}

/// Writes a subtitle edited in the player back to where it came from:
/// the sidecar SRT/ASS file, or the subtitle track inside the video.
///
/// The player shows cues after the subtitle package’s `flattenSubtitles` has stripped tags and
/// merged cues sharing a time range (or repeating across a gap), so a
/// displayed subtitle is not always one cue of the file. The edit is
/// therefore located by time: cues with exactly the subtitle's range are
/// the ones merged into it and collapse into the edited text; failing
/// that, the repeated cues inside the range whose text matches all take
/// the new text, keeping their own timing.
class SubtitleWriter {
  static final RegExp _srtTime =
      RegExp(r'(\d+):(\d{1,2}):(\d{1,2})[,.](\d+)');

  static final RegExp _assTime = RegExp(r'(\d+):(\d{1,2}):(\d{1,2})\.(\d+)');

  /// Tags the player strips before display, for comparing file text with
  /// the displayed text.
  static String _plain(String text) => text
      .replaceAll(RegExp('<[^>]*>'), '')
      .replaceAll(RegExp('{[^}]*}'), '')
      .replaceAll(r'\N', '\n')
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\h', ' ')
      .trim();

  /// Keep the formatting that wraps a whole cue — a leading override block
  /// such as `{\an8}` and an enclosing `<i>…</i>` — around [newText].
  static String _keepWrapping(String oldText, String newText) {
    String prefix = '';
    String body = oldText;
    Match? override = RegExp('^{[^}]*}').firstMatch(body);
    if (override != null) {
      prefix = override.group(0)!;
      body = body.substring(override.end);
    }
    Match? wrap = RegExp(r'^<(\w+)>[\s\S]*</\1>$').firstMatch(body.trim());
    if (wrap != null) {
      String tag = wrap.group(1)!;
      return '$prefix<$tag>$newText</$tag>';
    }
    return '$prefix$newText';
  }

  /// Apply the edit to [cues]; false when no cue matches the subtitle.
  static bool _applyEdit({
    required List<_Cue> cues,
    required Duration start,
    required Duration end,
    required String oldText,
    required String Function(_Cue cue) newTextFor,
  }) {
    List<_Cue> exact = cues
        .where((cue) =>
            cue.start == start &&
            cue.end == end &&
            _plain(cue.text).isNotEmpty)
        .toList();
    if (exact.isNotEmpty) {
      exact.first.text = newTextFor(exact.first);
      for (_Cue cue in exact.skip(1)) {
        cue.removed = true;
      }
      return true;
    }

    String plainOld = _plain(oldText);
    List<_Cue> repeats = cues
        .where((cue) =>
            cue.start >= start &&
            cue.end <= end &&
            _plain(cue.text) == plainOld)
        .toList();
    for (_Cue cue in repeats) {
      cue.text = newTextFor(cue);
    }
    return repeats.isNotEmpty;
  }

  /// Rewrite the cue(s) of SRT [content] behind the displayed subtitle
  /// [start]–[end] showing [oldText] so they read [newText]. Returns the
  /// new file content, or null when no cue matches. Line endings and a
  /// byte-order mark are preserved; cues are renumbered in order.
  static String? editSrt({
    required String content,
    required Duration start,
    required Duration end,
    required String oldText,
    required String newText,
  }) {
    bool bom = content.startsWith('﻿');
    bool crlf = content.contains('\r\n');
    String body = (bom ? content.substring(1) : content)
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trimRight();

    List<Object> blocks = [];
    List<_Cue> cues = [];
    Map<_Cue, String> timingLines = {};
    for (String block in body.split(RegExp(r'\n[ \t]*\n'))) {
      if (block.trim().isEmpty) {
        continue;
      }
      List<String> lines = block.split('\n');
      int timingIndex = lines.indexWhere((line) => line.contains('-->'));
      List<Match> times = timingIndex == -1
          ? []
          : _srtTime.allMatches(lines[timingIndex]).toList();
      if (times.length < 2) {
        blocks.add(block);
        continue;
      }
      _Cue cue = _Cue(
        start: _srtDuration(times[0]),
        end: _srtDuration(times[1]),
        text: lines.skip(timingIndex + 1).join('\n'),
      );
      timingLines[cue] = lines[timingIndex];
      cues.add(cue);
      blocks.add(cue);
    }

    bool found = _applyEdit(
      cues: cues,
      start: start,
      end: end,
      oldText: oldText,
      newTextFor: (cue) => _keepWrapping(cue.text, newText),
    );
    if (!found) {
      return null;
    }

    int number = 0;
    List<String> out = [];
    for (Object block in blocks) {
      if (block is _Cue) {
        if (block.removed) {
          continue;
        }
        number++;
        out.add('$number\n${timingLines[block]}\n${block.text}');
      } else {
        out.add(block as String);
      }
    }
    String result = '${out.join('\n\n')}\n';
    if (crlf) {
      result = result.replaceAll('\n', '\r\n');
    }
    return bom ? '﻿$result' : result;
  }

  /// SRT milliseconds are read as the subtitle package reads them — the
  /// digits as an integer — so the times compare equal with its cues.
  static Duration _srtDuration(Match match) => Duration(
        hours: int.parse(match.group(1)!),
        minutes: int.parse(match.group(2)!),
        seconds: int.parse(match.group(3)!),
        milliseconds: int.parse(match.group(4)!),
      );

  /// Rewrite the Dialogue event(s) of ASS [content] behind the displayed
  /// subtitle, as [editSrt] does for SRT. ASS keeps centiseconds; the
  /// player saw them through ffmpeg's SRT conversion as milliseconds.
  /// Only the edited events change: their override blocks before the text
  /// are kept, and line breaks become `\N`.
  static String? editAss({
    required String content,
    required Duration start,
    required Duration end,
    required String oldText,
    required String newText,
  }) {
    bool crlf = content.contains('\r\n');
    List<String> lines = content.replaceAll('\r\n', '\n').split('\n');

    List<String> format = [];
    bool inEvents = false;
    Map<_Cue, int> lineOf = {};
    Map<_Cue, String> headOf = {};
    List<_Cue> cues = [];
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      String trimmed = line.trim();
      if (trimmed.startsWith('[')) {
        inEvents = trimmed.toLowerCase() == '[events]';
        continue;
      }
      if (!inEvents) {
        continue;
      }
      if (trimmed.startsWith('Format:')) {
        format = trimmed
            .substring('Format:'.length)
            .split(',')
            .map((field) => field.trim().toLowerCase())
            .toList();
        continue;
      }
      if (!trimmed.startsWith('Dialogue:') || format.isEmpty) {
        continue;
      }
      int colon = line.indexOf(':');
      String values = line.substring(colon + 1);
      // The last field (Text) may itself contain commas.
      List<String> fields = [];
      int from = 0;
      for (int f = 0; f < format.length - 1; f++) {
        int comma = values.indexOf(',', from);
        if (comma == -1) {
          break;
        }
        fields.add(values.substring(from, comma));
        from = comma + 1;
      }
      if (fields.length != format.length - 1) {
        continue;
      }
      int startField = format.indexOf('start');
      int endField = format.indexOf('end');
      if (startField == -1 || endField == -1) {
        continue;
      }
      Match? s = _assTime.firstMatch(fields[startField]);
      Match? e = _assTime.firstMatch(fields[endField]);
      if (s == null || e == null) {
        continue;
      }
      _Cue cue = _Cue(
        start: _assDuration(s),
        end: _assDuration(e),
        text: values.substring(from),
      );
      lineOf[cue] = i;
      headOf[cue] = line.substring(0, colon + 1 + from);
      cues.add(cue);
    }

    bool found = _applyEdit(
      cues: cues,
      start: start,
      end: end,
      oldText: oldText,
      newTextFor: (cue) {
        String overrides =
            RegExp('^({[^}]*})*').firstMatch(cue.text)?.group(0) ?? '';
        return '$overrides${newText.replaceAll('\n', r'\N')}';
      },
    );
    if (!found) {
      return null;
    }

    Set<int> removedLines = {};
    for (_Cue cue in cues) {
      if (cue.removed) {
        removedLines.add(lineOf[cue]!);
      } else {
        lines[lineOf[cue]!] = '${headOf[cue]}${cue.text}';
      }
    }
    List<String> out = [
      for (int i = 0; i < lines.length; i++)
        if (!removedLines.contains(i)) lines[i],
    ];
    String result = out.join('\n');
    return crlf ? result.replaceAll('\n', '\r\n') : result;
  }

  static Duration _assDuration(Match match) {
    String fraction = match.group(4)!;
    // Centiseconds as written; tolerate a stray millisecond field.
    int ms = fraction.length >= 3
        ? int.parse(fraction.substring(0, 3))
        : int.parse(fraction.padRight(2, '0')) * 10;
    return Duration(
      hours: int.parse(match.group(1)!),
      minutes: int.parse(match.group(2)!),
      seconds: int.parse(match.group(3)!),
      milliseconds: ms,
    );
  }

  /// The start of the earliest cue in subtitle [content] (SRT, or ASS when
  /// [ass]), or null when it has none.
  static Duration? firstCueStart(String content, {required bool ass}) {
    Duration? first;
    for (String line in content.split(RegExp(r'\r?\n'))) {
      Match? match;
      if (ass) {
        // An empty event never reaches the player's SRT conversion.
        if (line.startsWith('Dialogue:') && !line.trimRight().endsWith(',')) {
          match = _assTime.firstMatch(line);
        }
      } else if (line.contains('-->')) {
        match = _srtTime.firstMatch(line);
      }
      if (match == null) {
        continue;
      }
      Duration start = ass ? _assDuration(match) : _srtDuration(match);
      if (first == null || start < first) {
        first = start;
      }
    }
    return first;
  }

  /// Rewrite a sidecar subtitle [file] (`.srt`, `.ass`, `.ssa`) in place.
  /// Throws with a reason when the cue cannot be found.
  static void editSubtitleFile({
    required File file,
    required Duration start,
    required Duration end,
    required String oldText,
    required String newText,
  }) {
    String content = file.readAsStringSync();
    String extension = path.extension(file.path).toLowerCase();
    String? edited = (extension == '.ass' || extension == '.ssa')
        ? editAss(
            content: content,
            start: start,
            end: end,
            oldText: oldText,
            newText: newText,
          )
        : editSrt(
            content: content,
            start: start,
            end: end,
            oldText: oldText,
            newText: newText,
          );
    if (edited == null) {
      throw StateError('The subtitle was not found in ${file.path}.');
    }
    file.writeAsStringSync(edited);
  }

  /// The subtitle streams of [videoPath], in container order.
  static Future<List<ContainerSubtitleStream>> probeSubtitleStreams(
    String videoPath,
  ) async {
    final session = await FFprobeKit.getMediaInformation(videoPath);
    final streams = session.getMediaInformation()?.getStreams() ?? [];
    List<ContainerSubtitleStream> result = [];
    for (final stream in streams) {
      final properties = stream.getAllProperties() ?? {};
      if (properties['codec_type'] != 'subtitle') {
        continue;
      }
      final tags = properties['tags'];
      final disposition = properties['disposition'];
      result.add(
        ContainerSubtitleStream(
          streamIndex: int.parse(properties['index'].toString()),
          ordinal: result.length,
          codec: properties['codec_name']?.toString() ?? '',
          tags: tags is Map
              ? tags.map((key, value) =>
                  MapEntry(key.toString(), value.toString()))
              : {},
          disposition: disposition is Map
              ? [
                  for (final entry in disposition.entries)
                    if (entry.value.toString() == '1') entry.key.toString(),
                ]
              : [],
        ),
      );
    }
    return result;
  }

  /// Extract subtitle track [stream] of [videoPath] into [output] with
  /// its timestamps exactly as stored — ASS unchanged, every other text
  /// codec as SRT. The player's own extraction runs without `-copyts`,
  /// so its cues can sit a few milliseconds later (the container's start
  /// offset); see [firstCueStart] for lining the two up.
  static Future<void> extractTrack({
    required String videoPath,
    required ContainerSubtitleStream stream,
    required File output,
  }) async {
    if (output.existsSync()) {
      output.deleteSync();
    }
    final session = await FFmpegKit.executeWithArguments([
      '-y',
      '-loglevel',
      'error',
      '-copyts',
      '-i',
      videoPath,
      '-map',
      '0:${stream.streamIndex}',
      '-c:s',
      stream.isAss ? 'copy' : 'srt',
      output.path,
    ]);
    if (!ReturnCode.isSuccess(await session.getReturnCode()) ||
        !output.existsSync()) {
      throw StateError('Could not extract subtitle track ${stream.ordinal}: '
          '${await session.getOutput()}');
    }
  }

  /// mkvmerge's per-track statistics: stale once the track changes.
  static final RegExp _statisticsTag =
      RegExp('^(_STATISTICS_|BPS|DURATION|NUMBER_OF_FRAMES|NUMBER_OF_BYTES)');

  /// Replace subtitle track [stream] of [videoPath] with [replacement]
  /// (an SRT, or for an ASS track the edited ASS), keeping every other
  /// stream, the track order, the track's language/title tags and its
  /// default/forced flags. Everything else is stream-copied into a hidden
  /// file beside the video, checked, and renamed over the original only
  /// once ffmpeg succeeded with all streams present.
  static Future<void> replaceTrack({
    required String videoPath,
    required ContainerSubtitleStream stream,
    required File replacement,
  }) async {
    String encoder = stream.isAss ? 'copy' : (stream.textEncoder ?? '');
    if (encoder.isEmpty) {
      throw StateError(
          'Subtitle track ${stream.ordinal} (${stream.codec}) cannot be '
          'written from text.');
    }

    final probe = await FFprobeKit.getMediaInformation(videoPath);
    final streams = probe.getMediaInformation()?.getStreams() ?? [];
    List<int> indexes = [
      for (final s in streams)
        int.parse((s.getAllProperties() ?? {})['index'].toString()),
    ];
    if (!indexes.contains(stream.streamIndex)) {
      throw StateError('Subtitle track ${stream.ordinal} is gone from the '
          'video.');
    }

    String directory = path.dirname(videoPath);
    String temp = path.join(
      directory,
      '.${path.basenameWithoutExtension(videoPath)}.subtitle-edit'
      '${path.extension(videoPath)}',
    );
    File tempFile = File(temp);
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }

    String n = '${stream.ordinal}';
    // -copyts: without it ffmpeg moves every copied stream by the
    // container's start offset (23 ms for a typical x264 MKV) on each
    // save, while the replacement track stays put.
    List<String> arguments = [
      '-y',
      '-loglevel',
      'error',
      '-copyts',
      '-i',
      videoPath,
      '-i',
      replacement.path,
      for (int index in indexes) ...[
        '-map',
        index == stream.streamIndex ? '1:0' : '0:$index',
      ],
      '-c',
      'copy',
      '-c:s:$n',
      encoder,
      for (final entry in stream.tags.entries)
        if (!_statisticsTag.hasMatch(entry.key)) ...[
          '-metadata:s:s:$n',
          '${entry.key}=${entry.value}',
        ],
      '-disposition:s:$n',
      stream.disposition.isEmpty ? '0' : stream.disposition.join('+'),
      temp,
    ];

    final session = await FFmpegKit.executeWithArguments(arguments);
    bool ok = ReturnCode.isSuccess(await session.getReturnCode()) &&
        tempFile.existsSync() &&
        tempFile.lengthSync() > 0;
    if (ok) {
      final check = await FFprobeKit.getMediaInformation(temp);
      ok = (check.getMediaInformation()?.getStreams() ?? []).length ==
          indexes.length;
    }
    if (!ok) {
      String output = await session.getOutput() ?? '';
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }
      throw StateError('Writing the subtitle into the video failed. $output'
          .trim());
    }

    tempFile.renameSync(videoPath);
  }
}
