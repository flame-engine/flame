import 'dart:ui';

import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show InlineSpan;

/// An [InlineTextNode] representing bold text.
class BoldTextNode extends InlineTextNode {
  BoldTextNode(this.child);

  BoldTextNode.simple(String text) : child = PlainTextNode(text);

  BoldTextNode.group(List<InlineTextNode> children)
    : child = GroupTextNode(children);

  final InlineTextNode child;

  static final defaultStyle = InlineTextStyle(fontWeight: FontWeight.bold);

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = FlameTextStyle.merge(parentTextStyle, stylesheet.boldText)!;
    child.fillStyles(stylesheet, style);
  }

  @override
  InlineSpan toInlineSpan() => child.toInlineSpan();
}
