import 'package:flame/src/text/nodes/inline_text_node.dart';
import 'package:flame/text.dart';

/// An [InlineTextNode] representing an inline code block string.
class CodeTextNode extends InlineTextNode {
  CodeTextNode(this.child);

  CodeTextNode.simple(String text) : child = PlainTextNode(text);

  CodeTextNode.group(List<InlineTextNode> children)
    : child = GroupTextNode(children);

  final InlineTextNode child;

  static final defaultStyle = InlineTextStyle(fontFamily: 'monospace');

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = FlameTextStyle.merge(parentTextStyle, stylesheet.codeText)!;
    child.fillStyles(stylesheet, style);
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => child.layoutBuilder;
}
