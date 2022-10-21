import 'dart:ui';

import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/elements/text_element.dart';
import 'package:flutter/rendering.dart' as flutter;

class TextPainterTextElement extends TextElement {
  TextPainterTextElement(this._textPainter)
      : _box = LineMetrics(
          ascent: _textPainter.computeDistanceToActualBaseline(
            flutter.TextBaseline.alphabetic,
          ),
          width: _textPainter.width,
          height: _textPainter.height,
        );

  final flutter.TextPainter _textPainter;
  final LineMetrics _box;

  @override
  LineMetrics get metrics => _box;

  @override
  void translate(double dx, double dy) => _box.translate(dx, dy);

  @override
  void render(Canvas canvas) {
    _textPainter.paint(canvas, Offset(_box.left, _box.top));
  }
}
