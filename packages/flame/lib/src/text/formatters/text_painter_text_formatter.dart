import 'package:flame/src/text/formatters/text_formatter.dart';
import 'package:flame/src/text/inline/text_painter_text_element.dart';
import 'package:flutter/rendering.dart';

/// This text formatter applies Flutter [TextStyle] to the a string of text,
/// creating a [TextPainterTextElement].
class TextPainterTextFormatter extends TextFormatter {
  TextPainterTextFormatter({
    required this.style,
    this.textDirection = TextDirection.ltr,
    this.debugMode = false,
  });

  final TextStyle style;
  final TextDirection textDirection;
  final bool debugMode;

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
