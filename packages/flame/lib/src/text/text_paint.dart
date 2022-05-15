import 'package:flutter/material.dart';

import '../anchor.dart';
import '../cache/memory_cache.dart';
import '../components/text_component.dart';
import '../extensions/size.dart';
import '../extensions/vector2.dart';
import 'text_renderer.dart';

/// It does not hold information regarding the position of the text to be
/// rendered, nor does it contain the text itself (the string).
/// To use that information, use the [TextComponent], which uses [TextPaint].
class TextPaint extends TextRenderer {
  static const TextStyle defaultTextStyle = TextStyle(
    color: Colors.white,
    fontFamily: 'Arial',
    fontSize: 24,
  );

  final MemoryCache<String, TextPainter> _textPainterCache = MemoryCache();
  final TextStyle style;

  final TextDirection textDirection;

  TextPaint({TextStyle? style, TextDirection? textDirection})
      : style = style ?? defaultTextStyle,
        textDirection = textDirection ?? TextDirection.ltr;

  @override
  void render(
    Canvas canvas,
    String text,
    Vector2 p, {
    Anchor anchor = Anchor.topLeft,
  }) {
    final tp = toTextPainter(text);
    final translatedPosition = anchor.translate(p, tp.size.toVector2());
    tp.paint(canvas, translatedPosition.toOffset());
  }

  @override
  Vector2 measureText(String text) {
    final tp = toTextPainter(text);
    return Vector2(tp.width, tp.height);
  }

  /// Returns a [TextPainter] that allows for text rendering and size
  /// measuring.
  ///
  /// A [TextPainter] has three important properties: paint, width and
  /// height (or size).
  ///
  /// Example usage:
  ///
  ///   const TextPaint config = TextPaint(fontSize: 48.0, fontFamily: 'Arial');
  ///   final tp = config.toTextPainter('Score: $score');
  ///   tp.paint(canvas, const Offset(10, 10));
  ///
  /// However, you probably want to use the [render] method which already
  /// takes the anchor into consideration.
  /// That way, you don't need to perform the math for that yourself.
  TextPainter toTextPainter(String text) {
    if (!_textPainterCache.containsKey(text)) {
      final span = TextSpan(
        style: style,
        text: text,
      );
      final tp = TextPainter(
        text: span,
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
    return TextPaint(style: transform(style), textDirection: textDirection);
  }
}
