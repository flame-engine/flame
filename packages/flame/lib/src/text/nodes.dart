class DocumentNode {
  DocumentNode(this.children);

  final List<BlockNode> children;
}

abstract class BlockNode {}

class ParagraphNode extends BlockNode {
  ParagraphNode(this.child);

  final GroupTextNode child;
}

class HeaderNode extends BlockNode {
  HeaderNode(this.child, {required this.level});

  final GroupTextNode child;
  final int level;
}

class BlockquoteNode extends BlockNode {
  BlockquoteNode(this.children);

  final List<BlockNode> children;
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
