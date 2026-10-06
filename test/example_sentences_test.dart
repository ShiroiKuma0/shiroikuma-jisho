import 'package:flutter_test/flutter_test.dart';
import 'package:shiroikumanojisho/utils.dart';

void main() {
  test('parses an A/B pair from examples.utf', () {
    final s = ExampleSentences.parse(
      'A: 彼は会えないことを残念に思った。\tHe regretted not being able to meet.#ID=1_2',
      'B: 彼(かれ)[01] は 会う{会えない} 事(こと){こと} を 残念[01]~ に 思う{思った}',
    )!;
    expect(s.japanese, '彼は会えないことを残念に思った。');
    expect(s.english, 'He regretted not being able to meet.');
    expect(s.words,
        containsAll(['彼', 'かれ', '会う', '事', 'こと', '残念', '思う']));
    expect(ExampleSentences.surfaceIn(s, '会う'), '会えない');
    expect(ExampleSentences.surfaceIn(s, '残念'), '残念');
  });

  test('skips a pair with no translation', () {
    expect(ExampleSentences.parse('A: 猫。', 'B: 猫'), isNull);
  });
}
