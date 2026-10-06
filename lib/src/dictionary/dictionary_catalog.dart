/// A Yomitan-format dictionary the app can download and import itself, so a
/// fresh install becomes a working dictionary without the user hunting for
/// zip files. Nothing here is bundled in the APK: each entry is fetched from
/// its maintainer's own stable URL at the moment the user asks for it.
///
/// Every URL was checked on 2026-10-05. The `latest/download` links follow
/// the maintainer's newest release, so the catalog stays current without an
/// app update; the two fixed links point at files their maintainers keep at
/// a permanent address.
class CatalogDictionary {
  /// Define a downloadable dictionary.
  const CatalogDictionary({
    required this.name,
    required this.description,
    required this.url,
    required this.approximateMegabytes,
    required this.titlePrefix,
    this.exactTitles = const [],
    this.recommended = false,
  });

  /// Name shown in the download list.
  final String name;

  /// One line saying what the dictionary adds.
  final String description;

  /// Direct download URL of the Yomitan zip.
  final String url;

  /// Download size, shown so the user can judge it on mobile data.
  final int approximateMegabytes;

  /// Start of the `title` in the zip's `index.json`. Titles carry a release
  /// date (`Jitendex.org [2026-10-03]`), so an installed copy is recognised
  /// by prefix rather than by exact name.
  final String titlePrefix;

  /// Further titles that identify an installed copy, for older releases
  /// whose title did not follow [titlePrefix]. Matched exactly, so a bare
  /// `JMdict` cannot be confused with `JMnedict` or `JMdict Forms`.
  final List<String> exactTitles;

  /// Whether the entry is ticked by default.
  final bool recommended;

  /// Whether a dictionary named [dictionaryName] is a copy of this entry.
  bool matches(String dictionaryName) =>
      dictionaryName.startsWith(titlePrefix) ||
      exactTitles.contains(dictionaryName);
}

/// Dictionaries offered for Japanese, in display order.
const List<CatalogDictionary> japaneseDictionaryCatalog = [
  CatalogDictionary(
    name: 'Jitendex',
    description: 'Japanese–English, built on JMdict with richer layout, '
        'notes and examples.',
    url: 'https://github.com/stephenmk/stephenmk.github.io/releases/latest/'
        'download/jitendex-yomitan.zip',
    approximateMegabytes: 39,
    titlePrefix: 'Jitendex',
    recommended: true,
  ),
  CatalogDictionary(
    name: 'JMdict (English)',
    description: 'The plain EDRDG Japanese–English dictionary. An '
        'alternative to Jitendex; both together repeat most entries.',
    url: 'https://github.com/yomidevs/jmdict-yomitan/releases/latest/'
        'download/JMdict_english.zip',
    approximateMegabytes: 16,
    titlePrefix: 'JMdict [',
    exactTitles: ['JMdict', 'JMdict (English)'],
  ),
  CatalogDictionary(
    name: 'KANJIDIC (English)',
    description: 'Kanji readings, meanings, stroke counts, grades and '
        'frequency.',
    url: 'https://github.com/yomidevs/jmdict-yomitan/releases/latest/'
        'download/KANJIDIC_english.zip',
    approximateMegabytes: 1,
    titlePrefix: 'KANJIDIC',
    recommended: true,
  ),
  CatalogDictionary(
    name: 'Kanjium pitch accents',
    description: 'Pitch accent patterns for headwords.',
    url: 'https://raw.githubusercontent.com/yomidevs/yomitan/dictionaries/'
        'kanjium_pitch_accents.zip',
    approximateMegabytes: 1,
    titlePrefix: 'Kanjium Pitch Accents',
    recommended: true,
  ),
  CatalogDictionary(
    name: 'JPDB frequency',
    description: 'Word frequency ranks from the JPDB corpus, used to order '
        'results.',
    url: 'https://github.com/Kuuuube/yomitan-dictionaries/releases/download/'
        'yomitan-permalink/JPDB_v2.2_Frequency_Kana.zip',
    approximateMegabytes: 6,
    titlePrefix: 'JPDBv2',
    recommended: true,
  ),
  CatalogDictionary(
    name: 'JPDB kanji frequency',
    description: 'How common each kanji is, for the kanji page.',
    url: 'https://github.com/MarvNC/yomichan-dictionaries/raw/master/dl/'
        '%5BKanji%20Frequency%5D%20JPDB%20Kanji.zip',
    approximateMegabytes: 1,
    titlePrefix: 'JPDB Kanji Freq',
    recommended: true,
  ),
  CatalogDictionary(
    name: 'JMnedict',
    description: 'Names of people and places. Large, and only useful when '
        'reading names.',
    url: 'https://github.com/yomidevs/jmdict-yomitan/releases/latest/'
        'download/JMnedict.zip',
    approximateMegabytes: 11,
    titlePrefix: 'JMnedict',
  ),
];
