import 'dart:ui';

import 'package:flame/text.dart';
import 'package:flutter/rendering.dart' as flutter;

class TextPainterTextElement extends InlineTextElement {
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
  void draw(Canvas canvas) {
    _textPainter.paint(canvas, Offset(_box.left, _box.top));
  }
}
