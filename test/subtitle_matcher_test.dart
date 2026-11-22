import 'package:flutter_test/flutter_test.dart';
import 'package:shiroikumanojisho/src/utils/player/subtitle_matcher.dart';

bool matches(String video, String subtitle) =>
    SubtitleMatcher.matches(videoPath: video, subtitlePath: subtitle);

void main() {
  group('episodeOf', () {
    test('reads explicit season and episode markers', () {
      expect(SubtitleMatcher.episodeOf('Show.S01E05.1080p.x264.mkv'),
          (season: 1, episode: 5));
      expect(SubtitleMatcher.episodeOf('Show 2x07.mkv'),
          (season: 2, episode: 7));
    });

    test('reads marked episodes without a season', () {
      expect(SubtitleMatcher.episodeOf('番組 第12話.mp4'),
          (season: null, episode: 12));
      expect(SubtitleMatcher.episodeOf('番組 第１２話.mp4'),
          (season: null, episode: 12));
      expect(SubtitleMatcher.episodeOf('Show EP03.srt'),
          (season: null, episode: 3));
      expect(SubtitleMatcher.episodeOf('Show #4.srt'),
          (season: null, episode: 4));
    });

    test('takes the last free number and ignores release noise', () {
      expect(
        SubtitleMatcher.episodeOf(
            '[Group] Show 2 - 05 [1080p][x265 10bit][AAC 2.0][1A2B3C4D].mkv'),
        (season: null, episode: 5),
      );
      expect(SubtitleMatcher.episodeOf('Show (2019) - 11 [1920x1080].mkv'),
          (season: null, episode: 11));
    });

    test('finds nothing in a name without numbers', () {
      expect(SubtitleMatcher.episodeOf('A Film.mkv'), isNull);
      expect(SubtitleMatcher.episodeOf('A Film [1080p].mkv'), isNull);
    });
  });

  group('matches', () {
    test('accepts a subtitle named after the video', () {
      expect(matches('/v/A Film.mkv', '/v/A Film.srt'), isTrue);
      expect(matches('/v/A Film.mkv', '/v/Subs/a film.ja.ass'), isTrue);
      expect(matches('/v/A Film.mkv', '/v/A Film [forced].srt'), isTrue);
    });

    test('does not let a shorter name claim a longer one', () {
      expect(matches('/v/Show 1.mkv', '/v/Show 10.srt'), isFalse);
      expect(matches('/v/A Film.mkv', '/v/A Filmography.srt'), isFalse);
    });

    test('accepts the same episode under a different name', () {
      expect(
        matches('/v/[Group] Show - 05 [1080p].mkv', '/s/Show.S01E05.ja.srt'),
        isTrue,
      );
      expect(matches('/v/番組 第3話.mp4', '/s/bangumi_03.srt'), isTrue);
    });

    test('rejects another episode or another season', () {
      expect(matches('/v/Show - 05.mkv', '/v/Show - 06.srt'), isFalse);
      expect(matches('/v/Show.S01E05.mkv', '/v/Show.S02E05.srt'), isFalse);
    });

    test('rejects unrelated names without numbers', () {
      expect(matches('/v/A Film.mkv', '/v/Another Film.srt'), isFalse);
    });
  });
}
