import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

part 'structured_content.mapper.dart';

/// Used for handling nested content when decoding [StructuredContent].
class ContentHook extends MappingHook {
  /// Initialise this object.
  const ContentHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is String) {
      return StructuredContentTextNode(text: value);
    } else if (value is List) {
      return StructuredContentChildContent(
        children: value
            .map(StructuredContent.processContent)
            .whereType<StructuredContent>()
            .toList(),
      );
    }

    return value;
  }
}

/// Wraps around all types of possible structured content.
@MappableClass(generateMethods: GenerateMethods.decode)
sealed class StructuredContent with StructuredContentMappable {
  /// Initialise this object.
  const StructuredContent({this.content});

  @MappableField(hook: ContentHook())

  /// Nested content.
  final StructuredContent? content;

  /// Handles nested content.
  static StructuredContent? processContent(var content) {
    if (content is String) {
      return StructuredContentTextNode(text: content);
    } else if (content is List) {
      return StructuredContentChildContent(
          children: content
              .map(processContent)
              .whereType<StructuredContent>()
              .toList());
    } else if (content is Map<String, dynamic>) {
      return StructuredContentMapper.fromMap(content);
    }

    return null;
  }

  /// Convert this to a valid HTML node.
  dom.Node toNode();
}

/// Styles that hide the renderer's marker on items flagged by
/// [StructuredContentStyledContainer.toNode]: items whose marker is
/// already in their text, and the items of a list styled `none`.
Map<String, Style> get listMarkerStyles => {
      'li[data-no-marker]': Style(marker: Marker(content: Content.none)),
      '[data-no-markers] > li': Style(marker: Marker(content: Content.none)),
    };

/// A structured-content `data` map as HTML attributes. Yomitan renders
/// `data: {content: "glossary"}` as `data-sc-content="glossary"`, and
/// dictionary stylesheets (Jitendex's styles.css) select on exactly that.
Map<String, String> dataAttributes(Map<String, String>? data) => {
      if (data != null)
        for (final e in data.entries) 'data-sc-${e.key}': e.value,
    };

/// Represents a text node.
@MappableClass(
  discriminatorValue: StructuredContentTextNode.checkType,
)
class StructuredContentTextNode extends StructuredContent
    with StructuredContentTextNodeMappable {
  /// Initialise this object.
  const StructuredContentTextNode({required this.text});

  /// Text for this node.
  final String text;

  @override
  dom.Node toNode() {
    return dom.Text(text);
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && value['text'] != null;
  }
}

/// An array of child content.
@MappableClass(discriminatorValue: StructuredContentChildContent.checkType)
class StructuredContentChildContent extends StructuredContent
    with StructuredContentChildContentMappable {
  /// Initialise this object.
  const StructuredContentChildContent({required this.children});

  /// Children to show.
  final List<StructuredContent> children;

  @override
  dom.Node toNode() {
    // A fragment, not a wrapping <div>: appending it puts the children
    // straight into the parent. A <div> broke every container whose
    // content is a list — <ruby><div>彼<rt>かの</rt></div></ruby> lost
    // its kanji, <ul><div><li> added a stray bullet level, and a span
    // with mixed content broke onto new lines.
    final fragment = dom.DocumentFragment();
    for (final child in children) {
      fragment.append(child.toNode());
    }

    return fragment;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is List;
  }
}

/// Represents a line break tag.
@MappableClass(discriminatorValue: StructuredContentLineBreak.checkType)
class StructuredContentLineBreak extends StructuredContent
    with StructuredContentLineBreakMappable {
  /// Initialise this object.
  StructuredContentLineBreak();

  @override
  dom.Node toNode() {
    return dom.Element.tag('br');
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && value['tag'] == 'br';
  }
}

/// Represents an image tag.
@MappableClass(discriminatorValue: StructuredContentImage.checkType)
class StructuredContentImage extends StructuredContent
    with StructuredContentImageMappable {
  /// Initialise this object.
  const StructuredContentImage({
    required this.path,
    this.width,
    this.height,
    this.title,
    this.description,
    this.pixelated = false,
    this.imageRendering = 'auto',
    this.appearance = 'auto',
    this.background = true,
    this.collapsed = false,
    this.collapsible = true,
    this.verticalAlign,
    this.sizeUnits,
  });

  /// Path to the image file in the archive.
  final String path;

  /// Preferred width of the image.
  final double? width;

  /// Preferred height of the image.
  final double? height;

  /// Hover text for the image.
  final String? title;

  /// Description of the image.
  final String? description;

  /// Whether or not the image should appear pixelated at sizes larger than
  /// the image's native resolution.
  final bool pixelated;

  /// Controls how the image is rendered. The value of this field supersedes
  /// the pixelated field.
  final String imageRendering;

  /// Controls the appearance of the image. The "monochrome" value will mask
  /// the opaque parts of the image using the current text color.
  final String appearance;

  /// Whether or not a background color is displayed behind the image.
  final bool background;

  /// Whether or not the image is collapsed by default.
  final bool collapsed;

  /// Whether or not the image can be collapsed.
  final bool collapsible;

  /// The vertical alignment of the image.
  final String? verticalAlign;

  /// The units for the width and height.
  final String? sizeUnits;

  @override
  dom.Node toNode() {
    final imageNode = dom.Element.tag('img');

    final srcAttr = 'jidoujisho://$path';
    final widthAttr = (width != null) ? '$width${sizeUnits ?? ''}' : null;
    final heightAttr = (height != null) ? '$height${sizeUnits ?? ''}' : null;
    final altAttr = description;

    imageNode.attributes.addAll(
      {
        'src': srcAttr,
        'alt': ?altAttr,
        'width': ?widthAttr,
        'height': ?heightAttr,
      },
    );

    if (title == null) {
      return imageNode;
    } else {
      final figureNode = dom.Element.tag('figure');
      final figcaptionNode = dom.Element.tag('figcaption')
        ..append(dom.Text(title));

      figureNode
        ..append(imageNode)
        ..append(figcaptionNode);

      return figureNode;
    }
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && (value['tag'] == 'img' || value['type'] == 'image');
  }
}

/// Represents an image tag.
@MappableClass(discriminatorValue: StructuredContentLink.checkType)
class StructuredContentLink extends StructuredContent
    with StructuredContentLinkMappable {
  /// Initialise this object.
  const StructuredContentLink({
    required this.href,
    super.content,
    this.lang,
  });

  /// The URL for the link. URLs starting with a ? are treated as internal
  /// links to other dictionary content.
  final String href;

  /// Defines the language of an element in the format defined by RFC 5646.
  final String? lang;

  @override
  dom.Node toNode() {
    final linkNode = dom.Element.tag('a');

    linkNode.attributes.addAll(
      {
        'href': href,
        'lang': ?lang,
      },
    );

    if (content != null) {
      linkNode.append(content!.toNode());
    }

    return linkNode;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && (value['tag'] == 'a');
  }
}

/// Generic container tags.
@MappableClass(discriminatorValue: StructuredContentContainer.checkType)
class StructuredContentContainer extends StructuredContent
    with StructuredContentContainerMappable {
  /// Initialise this object.
  const StructuredContentContainer({
    required this.tag,
    super.content,
    this.data,
    this.lang,
  });

  /// [tag] must match one of these tags.
  static List<String> validTags = [
    'ruby',
    'rt',
    'rp',
    'table',
    'thead',
    'tbody',
    'tfoot',
    'tr',
  ];

  /// Tag name. Must be any of the [validTags].
  final String tag;

  /// Additional attributes.
  final Map<String, String>? data;

  /// Defines the language of an element in the format defined by RFC 5646.
  final String? lang;

  @override
  dom.Node toNode() {
    final containerNode = dom.Element.tag(tag);

    containerNode.attributes.addAll({
      ...dataAttributes(data),
      'lang': ?lang,
    });

    if (content != null) {
      containerNode.append(content!.toNode());
    }

    return containerNode;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && validTags.contains(value['tag']);
  }
}

/// Stylable generic container tags.
@MappableClass(discriminatorValue: StructuredContentStyledContainer.checkType)
class StructuredContentStyledContainer extends StructuredContent
    with StructuredContentStyledContainerMappable {
  /// Initialise this object.
  const StructuredContentStyledContainer({
    required this.tag,
    super.content,
    this.style,
    this.data,
    this.lang,
  });

  /// [tag] must match one of these tags.
  static List<String> validTags = [
    'span',
    'div',
    'ol',
    'ul',
    'li',
  ];

  /// Tag name. Must be any of the [validTags].
  final String tag;

  /// Style for this container.
  final StructuredContentStyle? style;

  /// Additional attributes.
  final Map<String, String>? data;

  /// Defines the language of an element in the format defined by RFC 5646.
  final String? lang;

  @override
  dom.Node toNode() {
    final containerNode = dom.Element.tag(tag);

    // A quoted list-style-type ("①") is a literal marker and "none" no
    // marker; the renderer can draw neither from a style attribute. The
    // item carries the marker as text instead and is flagged so the
    // stylesheet suppresses the renderer's own (see [listMarkerStyles]).
    final String? marker = style?.literalMarker;
    final bool hideMarker = tag == 'li' &&
        (marker != null || style?.listStyleType == 'none');
    final bool isList = tag == 'ul' || tag == 'ol';
    final bool hideChildMarkers = isList &&
        (marker != null || style?.listStyleType == 'none');

    containerNode.attributes.addAll({
      ...dataAttributes(data),
      'lang': ?lang,
      if (style != null) 'style': style!.toInlineStyle(),
      if (hideMarker) 'data-no-marker': '',
      if (hideChildMarkers) 'data-no-markers': '',
    });

    if (tag == 'li' && marker != null) {
      containerNode.append(dom.Text('$marker '));
    }

    if (content != null) {
      containerNode.append(content!.toNode());
    }

    // A list styled with a literal marker (JMdict's "📝 " notes) puts it
    // in front of each of its items.
    if (isList && marker != null) {
      for (final item in containerNode.children) {
        if (item.localName == 'li') {
          item.nodes.insert(0, dom.Text('$marker '));
        }
      }
    }

    // Tag badges (part of speech, usage) have a right margin in the
    // dictionary's stylesheet, which the renderer ignores on inline
    // elements; without a space "derogatory" and "kana" run together.
    if (tag == 'span' && data?['class'] == 'tag') {
      return dom.DocumentFragment()
        ..append(containerNode)
        ..append(dom.Text(' '));
    }

    return containerNode;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && validTags.contains(value['tag']);
  }
}

/// Table tags.
@MappableClass(discriminatorValue: StructuredContentTableElement.checkType)
class StructuredContentTableElement extends StructuredContent
    with StructuredContentTableElementMappable {
  /// Initialise this object.
  const StructuredContentTableElement({
    required this.tag,
    super.content,
    this.style,
    this.data,
    this.colSpan,
    this.rowSpan,
    this.lang,
  });

  /// [tag] must match one of these tags.
  static List<String> validTags = [
    'td',
    'th',
  ];

  /// Tag name. Must be any of the [validTags].
  final String tag;

  /// Style for this node.
  final StructuredContentStyle? style;

  /// Additional attributes.
  final Map<String, String>? data;

  /// Column span.
  final int? colSpan;

  /// Row span.
  final int? rowSpan;

  /// Defines the language of an element in the format defined by RFC 5646.
  final String? lang;

  @override
  dom.Node toNode() {
    final node = dom.Element.tag(tag);

    node.attributes.addAll({
      ...dataAttributes(data),
      'lang': ?lang,
      if (style != null) 'style': style!.toInlineStyle(),
      if (colSpan != null) 'colspan': colSpan!.toString(),
      if (rowSpan != null) 'rowSpan': rowSpan!.toString(),
    });

    if (content != null) {
      node.append(content!.toNode());
    }

    return node;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && validTags.contains(value['tag']);
  }
}

/// Used to resolve [StructuredContentStyle.textDecorationLine] which can be
/// a [List] or a [String].
class TextDecorationLineHooker extends MappingHook {
  /// Initialise this object.
  const TextDecorationLineHooker();

  @override
  Object? beforeDecode(Object? value) {
    if (value is String) {
      return [value];
    }

    return value;
  }
}

/// Style for a [StructuredContent].
@MappableClass()
class StructuredContentStyle with StructuredContentStyleMappable {
  /// Initialise this object.
  const StructuredContentStyle({
    this.fontStyle = 'normal',
    this.fontWeight = 'normal',
    this.fontSize = 'medium',
    this.textDecorationLine = const [],
    this.verticalAlign = 'baseline',
    this.textAlign = 'start',
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.listStyleType = 'disc',
  });

  /// Valid list types.
  static List<String> validListStyleTypes =
      ListStyleType.values.map((e) => e.counterStyle).toList();

  /// Equivalent to 'font-style'.
  final String fontStyle;

  /// Equivalent to 'font-weight'.
  final String fontWeight;

  /// Equivalent to 'font-size'.
  final String fontSize;

  /// Equivalent to 'text-decoration-line'.
  @MappableField(hook: TextDecorationLineHooker())
  final List<String> textDecorationLine;

  /// Equivalent to 'vertical-align'.
  final String verticalAlign;

  /// Equivalent to 'text-align'.
  final String textAlign;

  /// Equivalent to 'margin-top'.
  final double marginTop;

  /// Equivalent to 'margin-left'.
  final double marginLeft;

  /// Equivalent to 'margin-right'.
  final double marginRight;

  /// Equivalent to 'margin-bottom'.
  final double marginBottom;

  /// Equivalent to 'list-style-type'.
  final String listStyleType;

  /// The marker text when [listStyleType] is a quoted string such as
  /// `"①"`, as Jitendex numbers its senses; null otherwise.
  String? get literalMarker {
    final match = RegExp(r'''^\s*["'](.*)["']\s*$''').firstMatch(listStyleType);
    return match?.group(1);
  }

  /// Convert this into an inline `style` attribute.
  ///
  /// Only properties the dictionary actually set are written. Writing every
  /// default (font-size: medium, margins of 0, list-style-type) made each
  /// element override the dictionary's own stylesheet, and turned every
  /// list's bullet into a square.
  String toInlineStyle() {
    final attributes = <String, String>{
      if (fontStyle != 'normal') 'font-style': fontStyle,
      if (fontWeight != 'normal') 'font-weight': fontWeight,
      if (fontSize != 'medium') 'font-size': fontSize,
      if (textDecorationLine.isNotEmpty)
        'text-decoration-line': textDecorationLine.join(' '),
      if (verticalAlign != 'baseline') 'vertical-align': verticalAlign,
      if (textAlign != 'start') 'text-align': textAlign,
      if (marginTop != 0) 'margin-top': '${marginTop}em',
      if (marginLeft != 0) 'margin-left': '${marginLeft}em',
      if (marginRight != 0) 'margin-right': '${marginRight}em',
      if (marginBottom != 0) 'margin-bottom': '${marginBottom}em',
      if (literalMarker == null &&
          listStyleType != 'disc' &&
          listStyleType != 'none' &&
          validListStyleTypes.contains(listStyleType))
        'list-style-type': listStyleType,
    };

    return attributes.entries.map((e) => '${e.key}:${e.value};').join();
  }
}
