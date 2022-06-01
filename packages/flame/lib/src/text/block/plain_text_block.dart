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

  @override
  void layout() {
    final topEdge = (padding?.top ?? 0) + (border?.top ?? 0);
    final leftEdge = (padding?.left ?? 0) + (border?.left ?? 0);
    final rightEdge = (padding?.right ?? 0) + (border?.right ?? 0);
    final bottomEdge = (padding?.bottom ?? 0) + (border?.bottom ?? 0);

    final bounds = LineMetrics(baseline: 0, left: leftEdge, right: rightEdge);
    var result = LayoutResult.unfinished;
    while (result == LayoutResult.unfinished) {
      result = _text.layOutNextLine(bounds);
    }
    final lines = _text.lines;

    // Vertical+horizontal alignment
    final textHeight = lines.map((line) => line.metrics.height).sum +
        (lines.length - 1) * _lineSpacing;
    if (height == 0) {
      height = textHeight + topEdge + bottomEdge;
    }
    final extraHeight = height - textHeight - topEdge - bottomEdge;
    var y0 = topEdge + (_verticalAlignment == TextAlign.end ? extraHeight : 0);
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
    super.layout();
  }

  @override
  void translate(double dx, double dy) {
    assert(_text.isLaidOut);
    _text.lines.forEach((line) => line.translate(dx, dy));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _text.render(canvas);
  }
}
