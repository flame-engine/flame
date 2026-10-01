import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show InlineSpan, TextSpan;

/// An [InlineTextNode] representing plain text.
class PlainTextNode extends InlineTextNode {
  PlainTextNode(this.text);

  final String text;

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = parentTextStyle;
  }

  @override
  InlineSpan toInlineSpan() {
    return TextSpan(text: text, style: style.asTextStyle());
  }
}
