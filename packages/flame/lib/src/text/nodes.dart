
/// An abstract base class for all entities with "block" placement rules.
abstract class BlockNode {}

class GroupBlockNode extends BlockNode {
  GroupBlockNode(this.children);

  final List<BlockNode> children;
}

class HeaderNode extends BlockNode {
  HeaderNode(this.child, {required this.level});

  final GroupTextNode child;
  final int level;
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
