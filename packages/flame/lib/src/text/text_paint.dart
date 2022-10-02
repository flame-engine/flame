import 'package:flame/src/cache/memory_cache.dart';
import 'package:flame/src/text/formatter_text_renderer.dart';
import 'package:flame/src/text/formatters/text_painter_text_formatter.dart';
import 'package:flame/src/text/text_renderer.dart';
import 'package:flutter/rendering.dart';

/// [TextRenderer] implementation based on Flutter's [TextPainter].
///
/// This renderer uses a fixed [style] to draw the text. This style cannot be
/// modified dynamically, if you need to change any attribute of the text at
/// runtime, such as color, then create a new [TextPaint] object using
/// [copyWith].
class TextPaint extends FormatterTextRenderer<TextPainterTextFormatter> {
  TextPaint({
    TextStyle? style,
    TextDirection? textDirection,
    @Deprecated('Use DebugTextFormatter instead. Will be removed in 1.5.0')
        bool? debugMode,
  }) : super(
          TextPainterTextFormatter(
            style: style ?? defaultTextStyle,
            textDirection: textDirection ?? TextDirection.ltr,
            // ignore: deprecated_member_use_from_same_package
            debugMode: debugMode ?? false,
          ),
        );

  TextStyle get style => formatter.style;

  TextDirection get textDirection => formatter.textDirection;

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
      style: transform(formatter.style),
      textDirection: textDirection ?? formatter.textDirection,
    );
  }
}
