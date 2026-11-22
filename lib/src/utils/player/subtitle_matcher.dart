import 'package:path/path.dart' as path;

/// Season and episode read out of a file name by
/// [SubtitleMatcher.episodeOf]. The season is null when the name carries
/// an episode number alone.
typedef EpisodeNumber = ({int? season, int episode});

/// Decides whether a subtitle file belongs to a video, going by the two
/// file names alone. Used by the external-subtitle picker in the player
/// to list the subtitles of the playing video first.
///
/// Pure Dart on purpose — no Flutter, no I/O — so it runs in a unit test.
class SubtitleMatcher {
  SubtitleMatcher._();

  /// Whether [subtitlePath] looks like the subtitle of [videoPath].
  ///
  /// Two ways to match:
  ///
  /// 1. The subtitle is named after the video — the same name, or the
  ///    video's name followed by a separator and a suffix
  ///    (`Episode 05.ja.srt`, `Episode 05 [forced].ass`).
  /// 2. Both names carry an episode number and the numbers agree. When
  ///    both also carry a season, the seasons must agree as well.
  ///
  /// Directories are not compared: a subtitle is as likely to sit in a
  /// `Subs` subdirectory as next to the video.
  static bool matches({
    required String videoPath,
    required String subtitlePath,
  }) {
    final String video = _stem(videoPath);
    final String subtitle = _stem(subtitlePath);
    if (video.isEmpty || subtitle.isEmpty) {
      return false;
    }

    if (subtitle == video) {
      return true;
    }
    if (subtitle.startsWith(video) &&
        !_isWordCharacter(subtitle[video.length])) {
      // `Show 1.srt` must not claim `Show 10.mkv`; a separator after
      // the video's name is what tells a suffix from a longer name.
      return true;
    }

    final EpisodeNumber? videoEpisode = episodeOf(videoPath);
    final EpisodeNumber? subtitleEpisode = episodeOf(subtitlePath);
    if (videoEpisode == null || subtitleEpisode == null) {
      return false;
    }
    if (videoEpisode.episode != subtitleEpisode.episode) {
      return false;
    }
    if (videoEpisode.season != null &&
        subtitleEpisode.season != null &&
        videoEpisode.season != subtitleEpisode.season) {
      return false;
    }

    return true;
  }

  /// The episode number in the file name of [filePath], or null when
  /// there is none to be found.
  ///
  /// Explicit markers win, in this order: `S01E05`, `1x05`, `第5話`,
  /// `EP05` / `Episode 5` / `E05` / `#05`. Failing those, the last
  /// free-standing number of one to four digits is taken, after
  /// resolutions, codecs, checksums and years have been struck out so
  /// that `[1080p]` or `x264` is never read as an episode.
  static EpisodeNumber? episodeOf(String filePath) {
    String name = _toHalfWidthDigits(_stem(filePath));

    RegExpMatch? match = _seasonEpisode.firstMatch(name);
    if (match != null) {
      return (
        season: int.parse(match.group(1)!),
        episode: int.parse(match.group(2)!),
      );
    }

    match = _seasonCrossEpisode.firstMatch(name);
    if (match != null) {
      return (
        season: int.parse(match.group(1)!),
        episode: int.parse(match.group(2)!),
      );
    }

    match = _japaneseEpisode.firstMatch(name) ?? _markedEpisode.firstMatch(name);
    if (match != null) {
      return (season: null, episode: int.parse(match.group(1)!));
    }

    for (final RegExp noise in _noise) {
      name = name.replaceAll(noise, ' ');
    }
    final List<RegExpMatch> numbers = _looseNumber.allMatches(name).toList();
    if (numbers.isEmpty) {
      return null;
    }

    return (season: null, episode: int.parse(numbers.last.group(1)!));
  }

  static final RegExp _seasonEpisode =
      RegExp(r'(?<![a-z0-9])s(\d{1,2})[ ._-]*e(\d{1,4})(?!\d)');
  static final RegExp _seasonCrossEpisode =
      RegExp(r'(?<![a-z0-9])(\d{1,2})x(\d{2,3})(?![a-z0-9])');
  static final RegExp _japaneseEpisode = RegExp(r'第\s*(\d{1,4})\s*[話回集]');
  static final RegExp _markedEpisode = RegExp(
      r'(?:(?<![a-z0-9])(?:episode|ep|e)[ ._-]*|#)(\d{1,4})(?![a-z0-9])');
  static final RegExp _looseNumber = RegExp(r'(?<![a-z0-9.])(\d{1,4})(?![a-z0-9])');

  /// Everything numeric in a release name that is not an episode.
  static final List<RegExp> _noise = [
    // A checksum in brackets: [1A2B3C4D].
    RegExp(r'[\[(][0-9a-f]{8}[\])]'),
    // Resolutions: 1080p, 720i, 1920x1080.
    RegExp(r'\d{3,4}[pi](?![a-z0-9])'),
    RegExp(r'\d{3,4}\s*x\s*\d{3,4}'),
    // Codecs, bit depths and channel layouts.
    RegExp('[xh][ .]?26[45]'),
    RegExp(r'\d{1,2}[ -]?bits?'),
    RegExp(r'(?:aac|ac3|dts|flac|ddp?|opus)[ ._-]?\d(?:\.\d)?'),
    RegExp(r'(?<![a-z0-9])\d\.\d(?![a-z0-9])'),
    // A year in brackets: (2019).
    RegExp(r'[\[(](?:19|20)\d{2}[\])]'),
  ];

  static String _stem(String filePath) {
    return path.basenameWithoutExtension(filePath).trim().toLowerCase();
  }

  static bool _isWordCharacter(String character) {
    return RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(character);
  }

  static String _toHalfWidthDigits(String text) {
    return text.replaceAllMapped(
      RegExp('[０-９]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xFEE0),
    );
  }
}
