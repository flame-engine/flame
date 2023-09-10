import 'package:flame/cache.dart';
import 'package:flame/text.dart';
import 'package:flutter/rendering.dart';

/// [TextPaint] applies a Flutter [TextStyle] to a string of
/// text, creating a [TextPainterTextElement].
class TextPaint extends TextRenderer {
  TextPaint({
    TextStyle? style,
    this.textDirection = TextDirection.ltr,
  }) : style = style ?? defaultTextStyle;

  final TextStyle style;
  final TextDirection textDirection;

  @override
  TextPainterTextElement format(String text) {
    final tp = toTextPainter(text);
    return TextPainterTextElement(tp);
  }

  final MemoryCache<String, TextPainter> _textPainterCache = MemoryCache();

  static const TextStyle defaultTextStyle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontFamily: 'Arial',
    fontSize: 24,
  );

  /// Returns a [TextPainter] that allows for text rendering and size
  /// measuring.
  ///
  /// A [TextPainter] has three important properties: paint, width and
  /// height (or size).
  ///
  /// Example usage:
  ///
  ///   const config = TextPaint(fontSize: 48.0, fontFamily: 'Arial');
  ///   final tp = config.toTextPainter('Score: $score');
  ///   tp.paint(canvas, const Offset(10, 10));
  ///
  /// However, you probably want to use the [render] method which already
  /// takes the anchor into consideration.
  /// That way, you don't need to perform the math for that yourself.
  TextPainter toTextPainter(String text) {
    if (!_textPainterCache.containsKey(text)) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: textDirection,
      );
      tp.layout();
      _textPainterCache.setValue(text, tp);
    }
    return _textPainterCache.getValue(text)!;
  }

  TextPaint copyWith(
    TextStyle Function(TextStyle) transform, {
    TextDirection? textDirection,
  }) {
    return TextPaint(
      style: transform(style),
      textDirection: textDirection ?? this.textDirection,
    );
  }
}
