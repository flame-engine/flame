import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show InlineSpan, TextSpan;

/// An [InlineTextNode] to group other [InlineTextNode]s.
class GroupTextNode extends InlineTextNode {
  GroupTextNode(this.children);

  final List<InlineTextNode> children;

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = parentTextStyle;
    for (final node in children) {
      node.fillStyles(stylesheet, style);
    }
  }

  @override
  InlineSpan toInlineSpan() {
    return TextSpan(
      style: style.asTextStyle(),
      children: [for (final child in children) child.toInlineSpan()],
    );
  }
}
