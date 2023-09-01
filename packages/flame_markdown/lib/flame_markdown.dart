import 'package:flame/text.dart';
import 'package:markdown/markdown.dart' as md;

class FlameMarkdown {
  static List<md.Node> parse(String text) {
    return md.Document().parse(text);
  }

  static DocumentNode convert(List<md.Node> nodes) {
    return DocumentNode(nodes.map(_convertNode).toList());
  }
  
  static BlockNode _convertNode(md.Node node) {
    if (node is md.Element) {
      return _convertElement(node);
    } else if (node is md.Text) {
      return _convertText(node);
    } else {
      throw Exception('Unknown node type: ${node.runtimeType}');
    }
  }

  static BlockNode _convertElement(md.Element element) {
    final children = (element.children ?? []).map(_convertNode).toList();
    switch (element.tag) {
      case 'h1':
        final singleChild = children.single as TextNode;
        return HeaderNode(singleChild, level: 1);
      case 'h2':
        return HeaderNode(children, level: 2);
      case 'h3':
        return HeaderNode(children, level: 3);
      case 'h4':
        return HeaderNode(children, level: 4);
      case 'h5':
        return HeaderNode(children, level: 5);
      case 'h6':
        return HeaderNode(children, level: 6);
      case 'p':
        return ParagraphNode(children);
      case 'ul':
        return UnorderedListNode(children);
      case 'ol':
        return OrderedListNode(children);
      case 'li':
        return ListItemNode(children);
      case 'a':
        return AnchorNode(children, element.attributes['href']);
      case 'img':
        return ImageNode(element.attributes['src']);
      case 'code':
        return CodeNode(children);
      case 'pre':
        return PreNode(children);
      case 'blockquote':
        return BlockquoteNode(children);
      case 'hr':
        return HorizontalRuleNode();
      case 'em':
        return EmphasisNode(children);
      case 'strong':
        return StrongNode(children);
      case 'del':
        return StrikethroughNode(children);
      case 'br':
        return LineBreakNode();
      case 'table':
        return TableNode(children);
      case 'thead':
        return TableHeadNode(children);
      case 'tbody':
        return TableBodyNode(children);
      case 'tr':
        return TableRowNode(children);
      case 'th':
        return TableHeaderNode(children);
      case 'td':
        return TableCellNode(children);
      default:
        throw Exception('Unknown element tag: ${element.tag}');
    }
  }

  static PlainTextNode _convertText(md.Text text) {
    return PlainTextNode(text.text);
  }
}
