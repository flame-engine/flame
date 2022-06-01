import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/src/text/block/text_block.dart';
import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class PlainTextBlock extends TextBlock {
  PlainTextBlock(
    this._text, {
    TextAlign horizontalAlignment = TextAlign.left,
    TextAlign verticalAlignment = TextAlign.start,
    double lineSpacing = 0,
  })  : _horizontalAlignment = horizontalAlignment,
        _verticalAlignment = verticalAlignment,
        _lineSpacing = lineSpacing;

  final TextElement _text;
  final TextAlign _horizontalAlignment;
  final TextAlign _verticalAlignment;
  final double _lineSpacing;
  double width = 0;
  double height = 0;

  @override
  void layout() {
    final bounds = LineMetrics(baseline: 0, left: 0, right: width);
    var result = LayoutResult.unfinished;
    while (result == LayoutResult.unfinished) {
      result = _text.layOutNextLine(bounds);
    }
    final lines = _text.lines;

    // Vertical+horizontal alignment
    final textHeight = lines.map((line) => line.metrics.height).sum +
        (lines.length - 1) * _lineSpacing;
    if (height == 0) {
      height = textHeight;
    }
    final extraHeight = height - textHeight;
    var y0 = _verticalAlignment == TextAlign.end ? extraHeight : 0;
    final lineDistance = _lineSpacing +
        (_verticalAlignment == TextAlign.justify && lines.length > 1
            ? extraHeight / (lines.length - 1)
            : 0);
    for (final line in lines) {
      final lineMetrics = line.metrics;
      final extraWidth = width - lineMetrics.width;
      final dy = y0 - lineMetrics.top;
      final dx = _horizontalAlignment == TextAlign.right
          ? extraWidth
          : _horizontalAlignment == TextAlign.center
              ? extraWidth / 2
              : 0.0;
      line.translate(dx, dy);
      y0 += lineMetrics.height + lineDistance;
    }
  }

  @override
  void render(Canvas canvas) {
    _text.render(canvas);
  }
}
