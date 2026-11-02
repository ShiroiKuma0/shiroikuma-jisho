import 'package:flutter_test/flutter_test.dart';
import 'package:shiroikumanojisho/src/utils/player/subtitle_writer.dart';

Duration t(int h, int m, int s, int ms) =>
    Duration(hours: h, minutes: m, seconds: s, milliseconds: ms);

void main() {
  group('editSrt', () {
    test('rewrites one cue and keeps the rest byte for byte', () {
      const srt = '1\n00:00:01,000 --> 00:00:02,500\nこんにちは\n\n'
          '2\n00:00:03,000 --> 00:00:04,000\n<i>さようなら</i>\n';
      final out = SubtitleWriter.editSrt(
        content: srt,
        start: t(0, 0, 1, 0),
        end: t(0, 0, 2, 500),
        oldText: 'こんにちは',
        newText: 'こんばんは\n二行目',
      );
      expect(
        out,
        '1\n00:00:01,000 --> 00:00:02,500\nこんばんは\n二行目\n\n'
        '2\n00:00:03,000 --> 00:00:04,000\n<i>さようなら</i>\n',
      );
    });

    test('keeps an enclosing tag, CRLF and the BOM', () {
      const srt = '﻿1\r\n00:00:03,000 --> 00:00:04,000\r\n'
          '{\\an8}<i>さようなら</i>\r\n';
      final out = SubtitleWriter.editSrt(
        content: srt,
        start: t(0, 0, 3, 0),
        end: t(0, 0, 4, 0),
        oldText: 'さようなら',
        newText: 'またね',
      );
      expect(out,
          '﻿1\r\n00:00:03,000 --> 00:00:04,000\r\n{\\an8}<i>またね</i>\r\n');
    });

    test('collapses cues the player merged by identical timing', () {
      const srt = '1\n00:00:01,000 --> 00:00:02,000\nA\n\n'
          '2\n00:00:01,000 --> 00:00:02,000\nB\n\n'
          '3\n00:00:05,000 --> 00:00:06,000\nC\n';
      final out = SubtitleWriter.editSrt(
        content: srt,
        start: t(0, 0, 1, 0),
        end: t(0, 0, 2, 0),
        oldText: 'A\nB',
        newText: 'AB',
      );
      expect(
        out,
        '1\n00:00:01,000 --> 00:00:02,000\nAB\n\n'
        '2\n00:00:05,000 --> 00:00:06,000\nC\n',
      );
    });

    test('rewrites every repeat the player merged across a gap', () {
      const srt = '1\n00:00:01,000 --> 00:00:02,000\nA\n\n'
          '2\n00:00:02,200 --> 00:00:03,000\nA\n';
      final out = SubtitleWriter.editSrt(
        content: srt,
        start: t(0, 0, 1, 0),
        end: t(0, 0, 3, 0),
        oldText: 'A',
        newText: 'Z',
      );
      expect(
        out,
        '1\n00:00:01,000 --> 00:00:02,000\nZ\n\n'
        '2\n00:00:02,200 --> 00:00:03,000\nZ\n',
      );
    });

    test('returns null when no cue matches', () {
      expect(
        SubtitleWriter.editSrt(
          content: '1\n00:00:01,000 --> 00:00:02,000\nA\n',
          start: t(0, 0, 9, 0),
          end: t(0, 0, 10, 0),
          oldText: 'A',
          newText: 'B',
        ),
        isNull,
      );
    });
  });

  group('editAss', () {
    const ass = '[Script Info]\nTitle: x\n\n[Events]\n'
        'Format: Layer, Start, End, Style, Name, MarginL, MarginR, '
        'MarginV, Effect, Text\n'
        'Dialogue: 0,0:00:01.00,0:00:02.50,Default,,0,0,0,,{\\i1}こんにちは, 世界\n'
        'Comment: 0,0:00:01.00,0:00:02.50,Default,,0,0,0,,note\n'
        'Dialogue: 0,0:00:03.00,0:00:04.00,Default,,0,0,0,,さようなら\n';

    test('rewrites the text field, keeps overrides, writes \\N', () {
      final out = SubtitleWriter.editAss(
        content: ass,
        start: t(0, 0, 1, 0),
        end: t(0, 0, 2, 500),
        oldText: 'こんにちは, 世界',
        newText: 'こんばんは\n世界',
      );
      expect(
        out,
        ass.replaceFirst('{\\i1}こんにちは, 世界', '{\\i1}こんばんは\\N世界'),
      );
    });
  });

  test('firstCueStart reads SRT and skips empty ASS events', () {
    expect(
      SubtitleWriter.firstCueStart(
          '1\n00:00:05,023 --> 00:00:06,000\nB\n\n'
          '2\n00:00:01,023 --> 00:00:02,000\nA\n',
          ass: false),
      t(0, 0, 1, 23),
    );
    expect(
      SubtitleWriter.firstCueStart(
          'Dialogue: 0,0:00:00.50,0:00:01.00,Default,,0,0,0,,\n'
          'Dialogue: 0,0:00:01.00,0:00:02.00,Default,,0,0,0,,A\n',
          ass: true),
      t(0, 0, 1, 0),
    );
  });
}
