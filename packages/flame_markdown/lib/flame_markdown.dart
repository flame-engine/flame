import 'package:flame/text.dart';
import 'package:markdown/markdown.dart' as md;

/// Helper to parse markdown strings into an AST structure provided by the
/// `markdown` package, and convert that structure into an equivalent
/// [DocumentRoot] from Flame.
/// 
/// This allows for the creation of rich-text components on Flame using a
/// very simple and easy-to-write markdown syntax.
class FlameMarkdown {

  // static TextElementComponent toComponent(String markdown) {}

  /// Converts a markdown string to a [DocumentRoot] from Flame.
  /// 
  /// This uses the `markdown` package to parse the markdown string
  /// into an AST structure, and then converts that structure into
  /// a [DocumentRoot] from Flame.
  static DocumentRoot toDocument(String markdown, { md.Document? document }) {
    final nodes = _parse(markdown, document: document);
    return DocumentRoot(
      nodes.map(_convertNode).map(_castCheck<BlockNode>).toList(),
    );
  }

  static List<md.Node> _parse(String markdown, { md.Document? document }) {
    return (document ?? md.Document()).parse(markdown);
  }

  static TextNode _convertNode(md.Node node) {
    if (node is md.Element) {
      return _convertElement(node);
    } else if (node is md.Text) {
      return _convertText(node);
    } else {
      throw Exception('Unknown node type: ${node.runtimeType}');
    }
  }

  static TextNode _convertElement(md.Element element) {
    final children = (element.children ?? [])
      .map(_convertNode)
      .map(_castCheck<InlineTextNode>)
      .toList();
    final child = _groupInlineChildren(children);
    switch (element.tag) {
      case 'h1':
        return HeaderNode(child, level: 1);
      case 'h2':
        return HeaderNode(child, level: 2);
      case 'h3':
        return HeaderNode(child, level: 3);
      case 'h4':
        return HeaderNode(child, level: 4);
      case 'h5':
        return HeaderNode(child, level: 5);
      case 'h6':
        return HeaderNode(child, level: 6);
      case 'p':
        return ParagraphNode(child);
      case 'em':
      case 'i':
        return ItalicTextNode(child);
      case 'strong':
      case 'b':
        return BoldTextNode(child);
      default:
        throw Exception('Unknown element tag: ${element.tag}');
    }
  }

  static PlainTextNode _convertText(md.Text text) {
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
