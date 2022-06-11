import 'package:flame/src/anchor.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/text/formatters/text_painter_text_formatter.dart';
import 'package:flame/src/text/text_renderer.dart';
import 'package:flutter/rendering.dart';

/// [TextRenderer] implementation based on Flutter's [TextPainter].
///
/// This renderer uses a fixed [style] to draw the text. This style cannot be
/// modified dynamically, if you need to change any attribute of the text at
/// runtime, such as color, then create a new [TextPaint] object using
/// [copyWith].
class TextPaint extends TextRenderer {
  TextPaint({TextStyle? style, TextDirection? textDirection, bool? debugMode})
      : formatter = TextPainterTextFormatter(
          style: style ?? defaultTextStyle,
          textDirection: textDirection ?? TextDirection.ltr,
          debugMode: debugMode ?? false,
        );

  final TextPainterTextFormatter formatter;

  TextStyle get style => formatter.style;

  TextDirection get textDirection => formatter.textDirection;

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
    final te = formatter.format(text);
    te.translate(
      p.x - te.metrics.width * anchor.x,
      p.y - te.metrics.height * anchor.y - te.metrics.top,
    );
    te.render(canvas);
  }

  @override
  Vector2 measureText(String text) {
    final te = formatter.format(text);
    return Vector2(te.metrics.width, te.metrics.height);
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
