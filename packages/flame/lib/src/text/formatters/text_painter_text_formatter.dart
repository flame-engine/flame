import 'package:flame/src/text/elements/text_painter_text_element.dart';
import 'package:flame/src/text/formatters/text_formatter.dart';
import 'package:flutter/rendering.dart';

/// [TextPainterTextFormatter] applies a Flutter [TextStyle] to a string of
/// text, creating a [TextPainterTextElement].
class TextPainterTextFormatter extends TextFormatter {
  TextPainterTextFormatter({
    required this.style,
    this.textDirection = TextDirection.ltr,
  });

  final TextStyle style; // NOTE: this is a Flutter TextStyle
  final TextDirection textDirection;

  @override
  TextPainterTextElement format(String text) {
    final tp = _textToTextPainter(text);
    return TextPainterTextElement(tp);
  }

  TextPainter _textToTextPainter(String text) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
    )..layout();
  }
}
