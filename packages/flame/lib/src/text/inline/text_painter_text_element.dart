import 'dart:ui';

import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/common/text_line.dart';
import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/elements/text_element.dart';
import 'package:flutter/rendering.dart' show TextBaseline, TextPainter;

class TextPainterTextElement extends TextElement implements TextLine, Element {
  TextPainterTextElement(this._textPainter)
      : _box = LineMetrics(
          ascent: _textPainter
              .computeDistanceToActualBaseline(TextBaseline.alphabetic),
          width: _textPainter.width,
          height: _textPainter.height,
        );

  final TextPainter _textPainter;
  final LineMetrics _box;

  @override
  LineMetrics get metrics => _box;

  @override
  TextLine get lastLine => this;

  @override
  void translate(double dx, double dy) => _box.translate(dx, dy);

  @override
  void render(Canvas canvas) {
    _textPainter.paint(canvas, Offset(_box.left, _box.top));
  }
}
