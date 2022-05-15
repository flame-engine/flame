import 'package:flame/src/anchor.dart';
import 'package:flame/src/cache/memory_cache.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/text/text_renderer.dart';
import 'package:flutter/rendering.dart';

/// [TextRenderer] implementation based on Flutter's [TextPainter].
///
/// This renderer uses a fixed [style] to draw the text. This style cannot be
/// modified dynamically, if you need to change any attribute of the text at
/// runtime, such as color, then create a new [TextPaint] object using
/// [copyWith].
class TextPaint extends TextRenderer {
  TextPaint({TextStyle? style, TextDirection? textDirection})
      : style = style ?? defaultTextStyle,
        textDirection = textDirection ?? TextDirection.ltr;

  final TextStyle style;

  final TextDirection textDirection;

  final MemoryCache<String, TextPainter> _textPainterCache = MemoryCache();

  static const TextStyle defaultTextStyle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontFamily: 'Arial',
    fontSize: 24,
  );

  @override
  void render(
    Canvas canvas,
    String text,
    Vector2 p, {
    Anchor anchor = Anchor.topLeft,
  }) {
    final tp = toTextPainter(text);
    final translatedPosition = Offset(
      p.x - tp.width * anchor.x,
      p.y - tp.height * anchor.y,
    );
    tp.paint(canvas, translatedPosition);
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
    return TextPaint(style: transform(style), textDirection: textDirection);
  }
}
