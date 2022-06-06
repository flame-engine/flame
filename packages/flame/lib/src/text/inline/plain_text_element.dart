import 'dart:ui';

import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/common/text_line.dart';
import 'package:flame/src/text/inline/text_element.dart';
import 'package:flutter/rendering.dart' show TextBaseline, TextPainter;

class PlainTextElement extends TextElement implements TextLine {
  PlainTextElement(this._textPainter)
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
  bool get isLaidOut => true;

  @override
  void resetLayout() {
    _box.translate(-_box.left, -_box.baseline);
  }

  @override
  LayoutResult layOutNextLine(LineMetrics bounds) {
    if (bounds.width < _textPainter.width) {
      return LayoutResult.didNotAdvance;
    }
    _box.translate(bounds.left, bounds.baseline);
    return LayoutResult.done;
  }

  @override
  Iterable<TextLine> get lines => [this];

  @override
  TextLine get lastLine => this;

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
