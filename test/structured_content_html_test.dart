// How Yomitan structured content becomes the HTML the dictionary renderer
// draws. Written 2026-10-05 after Jitendex entries showed stray bullet
// levels, run-together tag badges and example sentences with their kanji
// missing; the fixes were checked by rendering real Jitendex and JMdict
// entries to images.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/pages.dart';

String render(Object content) {
  final node = StructuredContent.processContent(content)!.toNode();
  final document = dom.Document.html('');
  document.body!.append(node);
  blockifyListItems(document.body!);
  return document.body!.innerHtml;
}

void main() {
  test('content lists are not wrapped in a div, so ruby keeps its kanji', () {
    final html = render(jsonDecode('''
      {"tag": "ruby", "content": ["彼", {"tag": "rt", "content": "かの"}]}
    '''));
    expect(html, '<ruby>彼<rt>かの</rt></ruby>');
  });

  test('data becomes data-sc-* attributes, without default inline styles',
      () {
    final html = render(jsonDecode('''
      {"tag": "ul", "data": {"content": "glossary"},
       "content": [{"tag": "li", "content": "dog"}]}
    '''));
    expect(html, '<ul data-sc-content="glossary"><li>dog</li></ul>');
  });

  test('a quoted list marker is written into the item', () {
    final html = render(jsonDecode('''
      {"tag": "li", "style": {"listStyleType": "\\"①\\""}, "content": "dog"}
    '''));
    expect(html, contains('① dog'));
    expect(html, contains('data-no-marker'));
  });

  test('tag badges are followed by a space', () {
    final html = render(jsonDecode('''
      [{"tag": "span", "data": {"class": "tag"}, "content": "derogatory"},
       {"tag": "span", "data": {"class": "tag"}, "content": "kana"}]
    '''));
    expect(html, contains('derogatory</span> <span'));
  });

  test('inline runs in a list item become blocks before its sublists', () {
    final html = render(jsonDecode('''
      {"tag": "li", "content": ["② ", {"tag": "ul", "content": [
        {"tag": "li", "content": "rat"}]}]}
    '''));
    expect(html, startsWith('<li><div>② </div><ul>'));
  });

  test('stylesheets: nesting flattened, unsupported values dropped', () {
    final sheet = parseDictionaryStylesheet('''
      li[data-sc-content="sense"] {
        padding-left: 0.25em;
        & ul[data-sc-content="glossary"] { list-style-type: none; }
      }
      div[data-sc-class="extra-box"] { width: fit-content; color: var(--x); }
      td > span { &::before { content: "x"; } }
    ''');
    expect(sheet.keys, contains('li[data-sc-content="sense"]'));
    expect(
        sheet.keys,
        contains(
            'li[data-sc-content="sense"] ul[data-sc-content="glossary"] > li'));
    expect(sheet.keys.where((k) => k.contains('extra-box')), isEmpty);
    expect(sheet.keys.where((k) => k.contains('::')), isEmpty);
  });

  test('written forms come from a simple forms list, not a forms table', () {
    final list = jsonEncode([
      {
        'tag': 'div',
        'data': {'content': 'forms'},
        'content': {
          'tag': 'ul',
          'content': [
            {'tag': 'li', 'content': '犬'},
            {'tag': 'li', 'content': '狗'},
            {'tag': 'li', 'content': 'イヌ'},
          ],
        },
      },
    ]);
    expect(extractWrittenForms([list]), ['犬', '狗', 'イヌ']);

    final table = jsonEncode({
      'tag': 'div',
      'data': {'content': 'forms'},
      'content': {'tag': 'table', 'content': []},
    });
    expect(extractWrittenForms([table]), isEmpty);
  });
}
