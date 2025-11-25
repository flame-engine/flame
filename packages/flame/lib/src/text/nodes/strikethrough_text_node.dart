import 'dart:ui';

import 'package:flame/src/text/nodes/inline_text_node.dart';
import 'package:flame/text.dart';

/// An [InlineTextNode] representing a text with a strikethrough line.
///
/// The exact styling can be controlled by the `strikethroughText` property
/// on the document style.
class StrikethroughTextNode extends InlineTextNode {
  StrikethroughTextNode(this.child);

  StrikethroughTextNode.simple(String text) : child = PlainTextNode(text);

  StrikethroughTextNode.group(List<InlineTextNode> children)
    : child = GroupTextNode(children);

  final InlineTextNode child;

  static final defaultStyle = InlineTextStyle(
    decoration: TextDecoration.lineThrough,
  );

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = FlameTextStyle.merge(
      parentTextStyle,
      stylesheet.strikethroughText,
    )!;
    child.fillStyles(stylesheet, style);
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => child.layoutBuilder;
}
