/// Conjugation tables for Japanese verbs and i-adjectives, generated from
/// the dictionary form and its part-of-speech code (JMdict's v1, v5k,
/// v5k-s, v5r-i, v5aru, v5u-s, vk, vs, vs-i, vs-s, adj-i, adj-ix).
class JapaneseConjugation {
  JapaneseConjugation._();

  /// The conjugation class [codes] describe, or null for words that do not
  /// conjugate (or classes not handled, such as classical verbs).
  static String? classOf(Iterable<String> codes) {
    const order = [
      'v5k-s', 'v5r-i', 'v5aru', 'v5u-s', 'v1', 'vk', 'vs-i', 'vs-s', 'vs',
      'v5u', 'v5k', 'v5g', 'v5s', 'v5t', 'v5n', 'v5b', 'v5m', 'v5r',
      'adj-ix', 'adj-i',
    ];
    final set = codes.toSet();
    for (final code in order) {
      if (set.contains(code)) return code;
    }
    return null;
  }

  /// The table for [term] in conjugation class [code]: rows of (form name,
  /// plain affirmative, plain negative, polite affirmative, polite
  /// negative), '' where a cell does not exist. Null when [code] is not a
  /// class this handles or [term] does not fit it.
  static List<(String, String, String, String, String)>? table(
      String term, String code) {
    if (code.startsWith('adj-i')) return _adjective(term, code == 'adj-ix');
    if (code == 'v1') return _ichidan(term);
    if (code == 'vk') return _kuru(term);
    // A noun taking する (勉強, vs) conjugates as 勉強する.
    if (code.startsWith('vs')) {
      return _suru(term.endsWith('する') ? term : '$termする');
    }
    if (code.startsWith('v5')) return _godan(term, code);
    return null;
  }

  static const _uToA = {
    'う': 'わ', 'く': 'か', 'ぐ': 'が', 'す': 'さ', 'つ': 'た',
    'ぬ': 'な', 'ぶ': 'ば', 'む': 'ま', 'る': 'ら',
  };
  static const _uToI = {
    'う': 'い', 'く': 'き', 'ぐ': 'ぎ', 'す': 'し', 'つ': 'ち',
    'ぬ': 'に', 'ぶ': 'び', 'む': 'み', 'る': 'り',
  };
  static const _uToE = {
    'う': 'え', 'く': 'け', 'ぐ': 'げ', 'す': 'せ', 'つ': 'て',
    'ぬ': 'ね', 'ぶ': 'べ', 'む': 'め', 'る': 'れ',
  };
  static const _uToO = {
    'う': 'お', 'く': 'こ', 'ぐ': 'ご', 'す': 'そ', 'つ': 'と',
    'ぬ': 'の', 'ぶ': 'ぼ', 'む': 'も', 'る': 'ろ',
  };

  /// The rows shared by all verbs, from their stems: [neg] (+ない), [cont]
  /// (+ます), [te] and [ta] (て/た forms), [potential], [passive] and
  /// [causative] (dictionary forms), [imperative], [volitional], [ba].
  static List<(String, String, String, String, String)> _verb({
    required String plain,
    required String neg,
    required String cont,
    required String te,
    required String ta,
    required String potential,
    required String passive,
    required String causative,
    required String causativePassive,
    required String imperative,
    required String volitional,
    required String ba,
    String? plainNegative,
    bool politeImperative = true,
    String? desireStem,
  }) {
    final String tai = desireStem ?? cont;
    final String nai = plainNegative ?? '$negない';
    final String naiStem = nai.substring(0, nai.length - 1);
    String ruNeg(String ichidan) =>
        '${ichidan.substring(0, ichidan.length - 1)}ない';
    String ruMasu(String ichidan) =>
        '${ichidan.substring(0, ichidan.length - 1)}ます';
    String ruMasen(String ichidan) =>
        '${ichidan.substring(0, ichidan.length - 1)}ません';
    return [
      ('Non-past', plain, nai, '$contます', '$contません'),
      ('Past', ta, '$naiStemかった', '$contました', '$contませんでした'),
      ('Te-form', te, '$naiStemくて', '$contまして', ''),
      ('Potential', potential, ruNeg(potential), ruMasu(potential),
          ruMasen(potential)),
      ('Passive', passive, ruNeg(passive), ruMasu(passive), ruMasen(passive)),
      ('Causative', causative, ruNeg(causative), ruMasu(causative),
          ruMasen(causative)),
      ('Causative passive', causativePassive, ruNeg(causativePassive),
          ruMasu(causativePassive), ruMasen(causativePassive)),
      ('Imperative', imperative, '$plainな',
          politeImperative ? '$contなさい' : '', ''),
      ('Volitional', volitional, '', '$contましょう', ''),
      ('Conditional (ば)', ba, '$naiStemければ', '', ''),
      ('Conditional (たら)', '$taら', '$naiStemかったら', '$contましたら',
          '$contませんでしたら'),
      ('Desire (たい)', '$taiたい', '$taiたくない', '$taiたいです',
          '$taiたくないです'),
    ];
  }

  static List<(String, String, String, String, String)>? _ichidan(String t) {
    if (!t.endsWith('る')) return null;
    final s = t.substring(0, t.length - 1);
    return _verb(
      plain: t,
      neg: s,
      cont: s,
      te: '$sて',
      ta: '$sた',
      potential: '$sられる',
      passive: '$sられる',
      causative: '$sさせる',
      causativePassive: '$sさせられる',
      imperative: '$sろ',
      volitional: '$sよう',
      ba: '$sれば',
    );
  }

  static List<(String, String, String, String, String)>? _godan(
      String t, String code) {
    if (t.isEmpty) return null;
    final c = t.substring(t.length - 1);
    final s = t.substring(0, t.length - 1);
    if (!_uToA.containsKey(c)) return null;

    final String a = _uToA[c]!;
    final String regularI = _uToI[c]!;
    String i = regularI;
    final String e = _uToE[c]!;
    final String o = _uToO[c]!;
    if (code == 'v5aru') i = 'い'; // いらっしゃいます, なさいます

    String te;
    String ta;
    if (code == 'v5k-s') {
      te = '$sって';
      ta = '$sった';
    } else if (code == 'v5u-s') {
      te = '$sうて';
      ta = '$sうた';
    } else {
      switch (c) {
        case 'く':
          te = '$sいて';
          ta = '$sいた';
        case 'ぐ':
          te = '$sいで';
          ta = '$sいだ';
        case 'す':
          te = '$sして';
          ta = '$sした';
        case 'ぬ' || 'ぶ' || 'む':
          te = '$sんで';
          ta = '$sんだ';
        default: // う, つ, る
          te = '$sって';
          ta = '$sった';
      }
    }

    return _verb(
      plain: t,
      neg: '$s$a',
      // ある: plain negative is ない, not あらない.
      plainNegative: code == 'v5r-i' ? '${s.substring(0, s.length - 1)}ない' : null,
      cont: '$s$i',
      te: te,
      ta: ta,
      potential: '$s$eる',
      passive: '$s$aれる',
      causative: '$s$aせる',
      causativePassive: c == 'す' ? '$s$aせられる' : '$s$aされる',
      imperative: code == 'v5aru' ? '$s$i' : '$s$e',
      // いらっしゃい is itself the polite command; no 〜なさい.
      politeImperative: code != 'v5aru',
      // The い stem is only for ます and the command: いらっしゃりたい.
      desireStem: '$s$regularI',
      volitional: '$s$oう',
      ba: '$s$eば',
    );
  }

  static List<(String, String, String, String, String)>? _kuru(String t) {
    // 来る keeps its kanji; くる changes vowel: こ (neg), き (cont), く.
    final bool kana = t.endsWith('くる');
    if (!kana && !t.endsWith('来る')) return null;
    final p = t.substring(0, t.length - 2);
    final String ko = kana ? '$pこ' : '$p来';
    final String ki = kana ? '$pき' : '$p来';
    final String ku = kana ? '$pく' : '$p来';
    return _verb(
      plain: t,
      neg: ko,
      cont: ki,
      te: '$kiて',
      ta: '$kiた',
      potential: '$koられる',
      passive: '$koられる',
      causative: '$koさせる',
      causativePassive: '$koさせられる',
      imperative: '$koい',
      volitional: '$koよう',
      ba: '$kuれば',
    );
  }

  static List<(String, String, String, String, String)>? _suru(String t) {
    if (!t.endsWith('する')) return null;
    final p = t.substring(0, t.length - 2);
    return _verb(
      plain: t,
      neg: '$pし',
      cont: '$pし',
      te: '$pして',
      ta: '$pした',
      potential: '$pできる',
      passive: '$pされる',
      causative: '$pさせる',
      causativePassive: '$pさせられる',
      imperative: '$pしろ',
      volitional: '$pしよう',
      ba: '$pすれば',
    );
  }

  static List<(String, String, String, String, String)>? _adjective(
      String t, bool ii) {
    if (!t.endsWith('い')) return null;
    String s = t.substring(0, t.length - 1);
    // いい / 良い conjugates from よ.
    if (ii) s = '${s.substring(0, s.length - 1)}よ';
    return [
      ('Non-past', t, '$sくない', '$tです', '$sくないです'),
      ('Past', '$sかった', '$sくなかった', '$sかったです', '$sくなかったです'),
      ('Te-form', '$sくて', '$sくなくて', '', ''),
      ('Adverb', '$sく', '', '', ''),
      ('Conditional (ば)', '$sければ', '$sくなければ', '', ''),
      ('Conditional (たら)', '$sかったら', '$sくなかったら', '', ''),
    ];
  }
}
