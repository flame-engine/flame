import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show InlineSpan;

/// An [InlineTextNode] representing a span of text with a custom style applied.
class CustomInlineTextNode extends InlineTextNode {
  final String styleName;

  CustomInlineTextNode(this.child, {required this.styleName});

  CustomInlineTextNode.simple(String text, {required this.styleName})
    : child = PlainTextNode(text);

  final InlineTextNode child;

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style =
        FlameTextStyle.merge(
          parentTextStyle,
          stylesheet.getCustomStyle(styleName),
        ) ??
        stylesheet.text;
    child.fillStyles(stylesheet, style);
  }

  @override
  InlineSpan toInlineSpan() => child.toInlineSpan();
}
