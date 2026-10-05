import 'package:flutter_html/flutter_html.dart';

/// Turns a Yomitan dictionary's `styles.css` into the selector → [Style] map
/// flutter_html applies, so a dictionary looks the way its author styled it
/// (Jitendex: no bullets on glosses, part-of-speech badges, example
/// boxes) instead of as bare nested lists.
///
/// The files are written for browsers and use CSS the renderer's parser
/// rejects outright — one error and it returns no rules at all. So the
/// sheet is taken apart here first:
///
///   * nested rules (`a { & b { … } }`) are flattened to `a b { … }`;
///   * comma-separated selectors become one rule each;
///   * rules for pseudo-elements (`::before`) and at-rules are dropped,
///     as are declarations using `var()`, `calc()`, `color-mix()` or
///     gradients, which the renderer cannot evaluate;
///   * `list-style-type` set to a quoted string ("＊") or `none` becomes a
///     marker on the list's items — the renderer draws no literal markers
///     and turns `none` into decimal numbers;
///   * widths and heights are dropped (`fit-content` collapses to zero);
///   * rules are ordered by specificity, because the renderer applies them
///     in order rather than by specificity — Jitendex's
///     `li[sense] ul[glossary] { list-style-type: none }` must beat its
///     later, less specific `ul[glossary] { list-style-type: disc }`;
///   * each rule is parsed on its own, so one the parser still dislikes
///     costs only itself.
Map<String, Style> parseDictionaryStylesheet(String css) {
  final rules = <_Rule>[];
  _flatten(css.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ''), '', rules);

  final indexed = rules.indexed.toList()
    ..sort((a, b) {
      final cmp = a.$2.specificity.compareTo(b.$2.specificity);
      return cmp != 0 ? cmp : a.$1.compareTo(b.$1);
    });

  final result = <String, Style>{};
  void add(String selector, Style style) {
    result[selector] = result[selector]?.merge(style) ?? style;
  }

  for (final (_, rule) in indexed) {
    final kept = <String>[];
    String? marker;
    for (final declaration in rule.declarations) {
      final colon = declaration.indexOf(':');
      if (colon < 0) continue;
      final property = declaration.substring(0, colon).trim().toLowerCase();
      final value = declaration.substring(colon + 1).trim();
      if (_unsupportedValue.hasMatch(value)) continue;

      // Sizes are left to the layout: the renderer reads Jitendex's
      // `width: fit-content` as zero and sets example sentences one
      // character per line.
      if (_sizeProperties.contains(property)) continue;

      if (property == 'list-style-type') {
        final quoted = RegExp(r'''^["'](.*)["']$''').firstMatch(value);
        if (quoted != null) {
          marker = '${quoted.group(1)} ';
        } else if (value == 'none') {
          // The renderer has no "none" counter and falls back to decimal
          // numbers; hiding the items' markers is what actually works.
          marker = '';
        } else if (_listStyleNames.contains(value)) {
          kept.add('list-style-type: $value');
        }
        continue;
      }
      kept.add('$property: $value');
    }

    if (kept.isNotEmpty) {
      try {
        final parsed = Style.fromCss('${rule.selector} { ${kept.join('; ')} }',
            (_, _) => null);
        for (final entry in parsed.entries) {
          add(entry.key, entry.value);
        }
      } catch (_) {
        // The renderer could not use this rule; the rest still apply.
      }
    }
    if (marker != null) {
      add('${rule.selector} > li',
          Style(marker: Marker(content: listMarker(marker))));
    }
  }

  return result;
}

/// A list item's marker content: [text] in place of the counter, or no
/// marker at all when it is empty.
Content listMarker(String text) =>
    text.isEmpty ? Content.none : Content(text);

const Set<String> _sizeProperties = {
  'width',
  'height',
  'min-width',
  'max-width',
  'min-height',
  'max-height',
};

class _Rule {
  _Rule(this.selector, this.declarations);

  final String selector;
  final List<String> declarations;

  /// (ids, classes/attributes/pseudo-classes, elements), packed into one
  /// comparable number.
  int get specificity {
    final ids = RegExp(r'#[\w-]+').allMatches(selector).length;
    final classes =
        RegExp(r'\.[\w-]+|\[[^\]]*\]|:[\w-]+').allMatches(selector).length;
    final stripped = selector
        .replaceAll(RegExp(r'\[[^\]]*\]'), ' ')
        .replaceAll(RegExp(r'[#.:][\w-]+'), ' ');
    final elements = RegExp(r'(^|[\s>+~])[a-zA-Z][\w-]*')
        .allMatches(stripped)
        .length;
    return ids * 10000 + classes * 100 + elements;
  }
}

final RegExp _unsupportedValue =
    RegExp(r'var\(|calc\(|color-mix\(|gradient\(|attr\(|env\(', caseSensitive: false);

final Set<String> _listStyleNames =
    ListStyleType.values.map((e) => e.counterStyle).toSet();

/// Walk [css] (the body of a block, or the whole sheet when [parent] is
/// empty) and append its rules to [out], with nested selectors resolved
/// against [parent].
void _flatten(String css, String parent, List<_Rule> out) {
  final declarations = <String>[];
  final buffer = StringBuffer();
  int i = 0;
  String? quote;

  while (i < css.length) {
    final c = css[i];
    if (quote != null) {
      buffer.write(c);
      if (c == quote) quote = null;
      i++;
      continue;
    }
    if (c == '"' || c == "'") {
      quote = c;
      buffer.write(c);
      i++;
    } else if (c == ';') {
      final d = buffer.toString().trim();
      if (d.isNotEmpty) declarations.add(d);
      buffer.clear();
      i++;
    } else if (c == '{') {
      final end = _matchingBrace(css, i);
      final header = buffer.toString().trim();
      buffer.clear();
      final body = css.substring(i + 1, end);
      i = end + 1;

      if (header.startsWith('@')) continue;
      final selectors = _resolve(header, parent)
          .where((s) => !s.contains('::') && !RegExp(r':(before|after)\b').hasMatch(s))
          .toList();
      for (final selector in selectors) {
        _flatten(body, selector, out);
      }
    } else if (c == '}') {
      i++;
    } else {
      buffer.write(c);
      i++;
    }
  }

  final tail = buffer.toString().trim();
  if (tail.isNotEmpty && parent.isNotEmpty) declarations.add(tail);
  if (parent.isNotEmpty && declarations.isNotEmpty) {
    out.add(_Rule(parent, declarations));
  }
}

/// Index of the `}` closing the `{` at [open].
int _matchingBrace(String css, int open) {
  int depth = 0;
  String? quote;
  for (int i = open; i < css.length; i++) {
    final c = css[i];
    if (quote != null) {
      if (c == quote) quote = null;
    } else if (c == '"' || c == "'") {
      quote = c;
    } else if (c == '{') {
      depth++;
    } else if (c == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return css.length;
}

/// The selectors of a rule header under [parent]: each comma-separated
/// part, with `&` replaced by every parent selector (or appended to it as
/// a descendant when there is no `&`).
List<String> _resolve(String header, String parent) {
  final parts = header
      .split(',')
      .map((s) => s.trim().replaceAll(RegExp(r'\s+'), ' '))
      .where((s) => s.isNotEmpty)
      .toList();
  if (parent.isEmpty) return parts;
  return [
    for (final part in parts)
      part.contains('&') ? part.replaceAll('&', parent) : '$parent $part',
  ];
}
