import 'package:flame/text.dart';
import 'package:markdown/markdown.dart';

/// Helper to parse markdown strings into an AST structure provided by the
/// `markdown` package, and convert that structure into an equivalent
/// [DocumentRoot] from Flame.
///
/// This allows for the creation of rich-text components on Flame using a
/// very simple and easy-to-write markdown syntax.
///
/// Note more advanced markdown features are not supported, such as tables,
/// code blocks, images, and inline HTML.
/// It is also possible that some otherwise valid markdown nestings of
/// block and inline-type elements are not currently supported.
class FlameMarkdown {
  /// Converts a markdown string to a [DocumentRoot] from Flame.
  ///
  /// This uses the `markdown` package to parse the markdown string
  /// into an AST structure, and then converts that structure into
  /// a [DocumentRoot] from Flame.
  static DocumentRoot toDocument(String markdown, {Document? document}) {
    final nodes = _parse(markdown, document: document);
    return DocumentRoot(
      nodes.map(_convertNode).map(_castCheck<BlockNode>).toList(),
    );
  }

  static List<Node> _parse(String markdown, {Document? document}) {
    return (document ?? _defaultDocument()).parse(markdown);
  }

  static Document _defaultDocument() {
    return Document(
      encodeHtml: false,
    );
  }

  static TextNode _convertNode(Node node) {
    if (node is Element) {
      return _convertElement(node);
    } else if (node is Text) {
      return _convertText(node);
    } else {
      throw Exception('Unknown node type: ${node.runtimeType}');
    }
  }

  static TextNode _convertElement(Element element) {
    final children = (element.children ?? [])
        .map(_convertNode)
        .map(_castCheck<InlineTextNode>)
        .toList();
    final child = _groupInlineChildren(children);

    final customClassName = element.attributes['class'];
    if (customClassName != null) {
      if (element.tag != 'span') {
        throw Exception(
          'Invalid markdown structure: '
          'Only <span> elements can have custom classes',
        );
      }
      return CustomInlineTextNode(child, styleName: customClassName);
    }

    return switch (element.tag) {
          'span' => child,
          'h1' => HeaderNode(child, level: 1),
          'h2' => HeaderNode(child, level: 2),
          'h3' => HeaderNode(child, level: 3),
          'h4' => HeaderNode(child, level: 4),
          'h5' => HeaderNode(child, level: 5),
          'h6' => HeaderNode(child, level: 6),
          'p' => ParagraphNode(child),
          'em' || 'i' => ItalicTextNode(child),
          'strong' || 'b' => BoldTextNode(child),
          'code' => CodeTextNode(child),
          'del' => StrikethroughTextNode(child),
          _ => throw Exception('Unknown element tag: ${element.tag}'),
        }
        as TextNode;
  }

  static PlainTextNode _convertText(Text text) {
    return PlainTextNode(text.text);
  }

  static InlineTextNode _groupInlineChildren(List<InlineTextNode> children) {
    if (children.isEmpty) {
      throw 'Invalid markdown structure: Found block element with no children';
    } else if (children.length == 1) {
      return children.single;
    } else {
      return GroupTextNode(children);
    }
  }

  static T _castCheck<T extends TextNode>(TextNode node) {
    if (node is T) {
      return node;
    } else {
      throw 'Invalid markdown structure: '
          'Expected $T but got ${node.runtimeType}';
    }
  }
}
