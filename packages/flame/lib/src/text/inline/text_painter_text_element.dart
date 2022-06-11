import 'dart:ui';

import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/common/text_line.dart';
import 'package:flame/src/text/inline/text_element.dart';
import 'package:flutter/rendering.dart' show TextBaseline, TextPainter;

class TextPainterTextElement extends TextElement implements TextLine {
  TextPainterTextElement(this._textPainter)
      : _box = LineMetrics(
          left: 0,
          baseline: 0,
          ascent: _textPainter
              .computeDistanceToActualBaseline(TextBaseline.alphabetic),
          width: _textPainter.width,
          height: _textPainter.height,
        );

  final TextPainter _textPainter;
  final LineMetrics _box;

  @override
  void resetLayout() => _box.moveToOrigin();

  @override
  LayoutResult layOutNextLine(LineMetrics bounds) {
    if (bounds.width < _textPainter.width) {
      return LayoutResult.didNotAdvance;
    }
    _box.translate(bounds.left, bounds.baseline);
    return LayoutResult.done;
  }

  @override
  LineMetrics get metrics => _box;

  @override
  void translate(double dx, double dy) {
    _box.translate(dx, dy);
  }

  @override
  void render(Canvas canvas) {
    _textPainter.paint(canvas, Offset(_box.left, _box.top));
  }
}
