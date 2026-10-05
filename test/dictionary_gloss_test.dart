// The English → Japanese search matches queries against glosses pulled out
// of stored definitions by DictionaryGloss. These pin down the extraction
// and normalisation rules on real Jitendex / JMdict shapes; ranking was
// checked by hand against a full Jitendex + JPDB import (2026-10-05).

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shiroikumanojisho/dictionary.dart';

void main() {
  group('normalise', () {
    test('drops the infinitive "to" and articles', () {
      expect(DictionaryGloss.normalise('to eat'), 'eat');
      expect(DictionaryGloss.normalise('a dog'), 'dog');
      expect(DictionaryGloss.normalise('The House'), 'house');
    });

    test('keeps a lone leading word', () {
      expect(DictionaryGloss.normalise('to'), 'to');
    });

    test('removes nested asides entirely', () {
      // Jitendex's 犬: a flat regex left "dog familiaris" and lost the
      // exact match.
      expect(DictionaryGloss.normalise('dog (Canis (lupus) familiaris)'),
          'dog');
      expect(DictionaryGloss.normalise('to give up [on something]'),
          'give up');
    });

    test('keeps apostrophes, drops other punctuation', () {
      expect(DictionaryGloss.normalise("don't mind!"), "don't mind");
    });
  });

  group('extractGlosses', () {
    test('reads only glossary lists from structured content', () {
      final content = jsonEncode([
        {
          'tag': 'div',
          'data': {'content': 'sense'},
          'content': [
            {
              'tag': 'ul',
              'data': {'content': 'glossary'},
              'content': [
                {'tag': 'li', 'content': 'shape up!'},
                {'tag': 'li', 'content': 'act properly!'},
              ],
            },
            {
              'tag': 'div',
              'data': {'content': 'example-sentence'},
              'content': 'This sentence must not be indexed.',
            },
          ],
        },
        {
          'tag': 'ul',
          'data': {'content': 'glossary'},
          'content': {'tag': 'li', 'content': 'second sense'},
        },
      ]);
      expect(DictionaryGloss.extractGlosses([content]), [
        (0, 'shape up!'),
        (0, 'act properly!'),
        (1, 'second sense'),
      ]);
    });

    test('splits plain-text definitions on semicolons, one sense each', () {
      expect(DictionaryGloss.extractGlosses(['to eat; to live on', 'meal']),
          [(0, 'to eat'), (0, 'to live on'), (1, 'meal')]);
    });
  });

  group('forEntry', () {
    test('skips Japanese-only definitions', () {
      expect(
          DictionaryGloss.forEntry(
              entryId: 1, dictionaryId: 1, definitions: ['食物を口に入れる。']),
          isNull);
    });

    test('indexes words and senses', () {
      final row = DictionaryGloss.forEntry(
          entryId: 7, dictionaryId: 2, definitions: ['to eat', 'to live on']);
      expect(row!.glosses, ['0\teat', '1\tlive on']);
      expect(row.words, unorderedEquals(['eat', 'live', 'on']));
    });
  });
}
