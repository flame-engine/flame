import 'package:flame/src/text/formatters/text_formatter.dart';
import 'package:flame/src/text/inline/debug_text_painter_text_element.dart';
import 'package:flame/src/text/inline/text_painter_text_element.dart';
import 'package:flutter/rendering.dart' as flutter;

/// [TextPainterTextFormatter] applies a [flutter.TextStyle] to a string of
/// text, creating a [TextPainterTextElement].
///
/// If the [debugMode] is true, this formatter will wrap the text with a
/// [DebugTextPainterTextElement] instead. This mode is mostly useful for tests.
class TextPainterTextFormatter extends TextFormatter {
  TextPainterTextFormatter({
    required this.style,
    this.textDirection = flutter.TextDirection.ltr,
    this.debugMode = false,
  });

  final flutter.TextStyle style;
  final flutter.TextDirection textDirection;
  final bool debugMode;

  @override
  TextPainterTextElement format(String text) {
    final tp = _textToTextPainter(text);
    if (debugMode) {
      return DebugTextPainterTextElement(tp);
    } else {
      return TextPainterTextElement(tp);
    }
  }

  flutter.TextPainter _textToTextPainter(String text) {
    return flutter.TextPainter(
      text: flutter.TextSpan(text: text, style: style),
      textDirection: textDirection,
    )..layout();
  }
}
