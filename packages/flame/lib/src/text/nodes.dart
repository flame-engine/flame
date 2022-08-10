import 'package:flame/src/text/nodes/block_node.dart';

class GroupBlockNode extends BlockNode {
  GroupBlockNode(this.children);

  final List<BlockNode> children;
}

class BlockquoteNode extends GroupBlockNode {
  BlockquoteNode(super.children);
}

abstract class TextNode {}

class PlainTextNode extends TextNode {
  PlainTextNode(this.text);

  final String text;
}

class GroupTextNode extends TextNode {
  GroupTextNode(this.children);

  final List<TextNode> children;
}

class BoldTextNode extends GroupTextNode {
  BoldTextNode(super.children);
}

class ItalicTextNode extends GroupTextNode {
  ItalicTextNode(super.children);
}

class StrikethroughTextNode extends GroupTextNode {
  StrikethroughTextNode(super.children);
}

class HighlightedTextNode extends GroupTextNode {
  HighlightedTextNode(super.children);
}
