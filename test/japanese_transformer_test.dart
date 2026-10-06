// The Dart port of Yomitan's Japanese deinflection must give exactly what
// Yomitan gives. The expected lists were produced by running Yomitan's own
// LanguageTransformer (commit 67db60dd) under Node on these words and
// keeping the dictionary-form candidates, as
// JapaneseTransformer.dictionaryForms does. Odd candidates such as 行っる
// are Yomitan's too: it leaves them for the dictionary lookup to discard.

import 'package:flutter_test/flutter_test.dart';
import 'package:shiroikumanojisho/src/language/implementations/japanese_transformer.dart';

void main() {
  const expected = <String, List<String>>{
    '食べさせられた': ['食べさせられる', '食べさせる', '食べさせらる', '食べさする', '食べる', '食べす', '食べする', '食べさす', '食ぶ'],
    '行った': ['行っる', '行う', '行つ', '行る', '行く'],
    '来ない': ['来ないる', '来なう', '来る'],
    'しなかった': ['しない', 'しなかっる', 'しなかう', 'しなかつ', 'しなかる', 'しる', 'する'],
    '美しくなかった': ['美しくない', '美しくなかっる', '美しくなかう', '美しくなかつ', '美しくなかる', '美しい', '美しくる'],
    '読んでいる': ['読ぬ', '読ぶ', '読む'],
    '書かれる': ['書く', '書かる'],
    '見せてください': ['見せてくださいる', '見せてくださう'],
    '走りました': ['走りましる', '走ります', '走りまする', '走りむ', '走りる', '走る'],
    '飲みたくない': ['飲みたくないる', '飲みたくなう', '飲みたい', '飲みたくる', '飲みる', '飲む'],
    '言わなければ': ['言わない', '言わなける', '言わる', '言う', '言わなく'],
    '泳いだ': ['泳ぐ'],
    '死んだ': ['死ぬ', '死ぶ', '死む'],
    '待って': ['待っる', '待う', '待つ', '待る', '待っつ', '待ってる'],
    '買わせる': ['買う', '買わす'],
    '食べちゃった': ['食べちゃっる', '食べちゃう', '食べちゃつ', '食べちゃる', '食べる', '食ぶ'],
    '読める': ['読む'],
    '高すぎる': ['高い', '高る'],
    '勉強します': ['勉強しむ', '勉強しる', '勉強す', '勉強する'],
    '知らん': ['知らる', '知る'],
  };

  for (final entry in expected.entries) {
    test(entry.key, () {
      expect(JapaneseTransformer.instance.dictionaryForms(entry.key),
          entry.value);
    });
  }
}
