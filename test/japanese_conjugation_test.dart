// Every form in a generated conjugation table must deinflect back to its
// dictionary form with the Yomitan rule set the search uses — the two are
// written independently, so agreement checks both.

import 'package:flutter_test/flutter_test.dart';
import 'package:shiroikumanojisho/src/language/implementations/japanese_conjugation.dart';
import 'package:shiroikumanojisho/src/language/implementations/japanese_transformer.dart';

/// Correct forms Yomitan's rules do not undo, so the round trip cannot
/// check them: the prohibitive 〜な, a polite です after an adjective form,
/// 〜ませんでしたら, ある's suppletive negative ない, and いらっしゃい.
/// (いい conjugates through よい, which is what Yomitan returns.)
bool _beyondYomitan(String term, String row, String form) =>
    form.endsWith('です') ||
    form.endsWith('ませんでしたら') ||
    (row == 'Imperative' && form.endsWith('な')) ||
    (term == 'ある' && form.startsWith('な')) ||
    (term == 'いらっしゃる' && form == 'いらっしゃい');

void main() {
  const words = {
    '食べる': 'v1',
    '書く': 'v5k',
    '泳ぐ': 'v5g',
    '話す': 'v5s',
    '待つ': 'v5t',
    '死ぬ': 'v5n',
    '遊ぶ': 'v5b',
    '読む': 'v5m',
    '帰る': 'v5r',
    '買う': 'v5u',
    '行く': 'v5k-s',
    'ある': 'v5r-i',
    'いらっしゃる': 'v5aru',
    '問う': 'v5u-s',
    '来る': 'vk',
    'する': 'vs-i',
    '勉強する': 'vs',
    '高い': 'adj-i',
    'いい': 'adj-ix',
  };

  for (final entry in words.entries) {
    test('${entry.key} (${entry.value})', () {
      final table = JapaneseConjugation.table(entry.key, entry.value)!;
      final misses = <String>[];
      for (final (name, a, b, c, d) in table) {
        for (final form in [a, b, c, d]) {
          if (form.isEmpty || form == entry.key) continue;
          if (_beyondYomitan(entry.key, name, form)) continue;
          final forms = JapaneseTransformer.instance.dictionaryForms(form);
          final target = entry.key == 'いい' ? 'よい' : entry.key;
          if (!forms.contains(target)) misses.add('$name: $form');
        }
      }
      expect(misses, isEmpty);
    });
  }

  test('spot checks', () {
    String cell(String term, String code, String row, int column) {
      final r = JapaneseConjugation.table(term, code)!
          .firstWhere((r) => r.$1 == row);
      return [r.$2, r.$3, r.$4, r.$5][column];
    }

    expect(cell('行く', 'v5k-s', 'Past', 0), '行った');
    expect(cell('ある', 'v5r-i', 'Non-past', 1), 'ない');
    expect(cell('いらっしゃる', 'v5aru', 'Non-past', 2), 'いらっしゃいます');
    expect(cell('来る', 'vk', 'Imperative', 0), '来い');
    expect(cell('くる', 'vk', 'Non-past', 1), 'こない');
    expect(cell('話す', 'v5s', 'Causative passive', 0), '話させられる');
    expect(cell('いい', 'adj-ix', 'Past', 0), 'よかった');
    expect(cell('勉強する', 'vs', 'Potential', 0), '勉強できる');
    expect(cell('勉強', 'vs', 'Past', 0), '勉強した');
  });
}
