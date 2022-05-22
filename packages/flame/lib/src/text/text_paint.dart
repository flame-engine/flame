import 'package:flame/src/anchor.dart';
import 'package:flame/src/cache/memory_cache.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/text/inline_text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:flame/src/text/text_line.dart';
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

  @override
  InlineTextElement forge(String text) {
    return _TextPaintRun(toTextPainter(text));
  }
}

class _TextPaintRun extends InlineTextElement implements TextLine {
  _TextPaintRun(this._textPainter);

  final TextPainter _textPainter;
  double? _x0;
  double? _y0;

  @override
  bool get isLaidOut => _x0 != null && _y0 != null;

  @override
  int get numLinesLaidOut => _x0 == null ? 0 : 1;

  @override
  void resetLayout() => _x0 = null;

  @override
  LayoutStatus layOutNextLine(double x0, double x1, double baseline) {
    _x0 = x0;
    _y0 = baseline -
        _textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    return LayoutStatus.done;
  }

  @override
  TextLine line(int line) => this;

  @override
  LineMetrics get metrics {
    assert(isLaidOut);
    return LineMetrics(
      left: _x0!,
      right: _x0! + _textPainter.width,
      top: _y0!,
      bottom: _y0! + _textPainter.height,
      baseline: _y0! +
          _textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
    );
  }

  @override
  void render(Canvas canvas) {
    assert(isLaidOut);
    _textPainter.paint(canvas, Offset(_x0!, _y0!));
  }
}
