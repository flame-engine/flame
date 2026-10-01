import 'dart:ui';

import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show InlineSpan;

/// An [InlineTextNode] representing italic text.
class ItalicTextNode extends InlineTextNode {
  ItalicTextNode(this.child);

  ItalicTextNode.simple(String text) : child = PlainTextNode(text);

  ItalicTextNode.group(List<InlineTextNode> children)
    : child = GroupTextNode(children);

  final InlineTextNode child;

  static final defaultStyle = InlineTextStyle(fontStyle: FontStyle.italic);

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = FlameTextStyle.merge(parentTextStyle, stylesheet.italicText)!;
    child.fillStyles(stylesheet, style);
  }

  @override
  InlineSpan toInlineSpan() => child.toInlineSpan();
}
