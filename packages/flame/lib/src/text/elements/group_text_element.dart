import 'dart:math';
import 'dart:ui';

import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/elements/text_element.dart';

class GroupTextElement extends TextElement {
  GroupTextElement(List<TextElement> children)
      : assert(children.isNotEmpty, 'The children list cannot be empty'),
        _children = children,
        _metrics = _computeMetrics(children);

  final List<TextElement> _children;
  final LineMetrics _metrics;

  @override
  LineMetrics get metrics => _metrics;

  @override
  void render(Canvas canvas) {
    for (final child in _children) {
      child.render(canvas);
    }
  }

  @override
  void translate(double dx, double dy) {
    _metrics.translate(dx, dy);
    for (final child in _children) {
      child.translate(dx, dy);
    }
  }

  static LineMetrics _computeMetrics(List<TextElement> elements) {
    var width = 0.0;
    var ascent = 0.0;
    var descent = 0.0;
    for (final element in elements) {
      final metrics = element.metrics;
      assert(metrics.left == width);
      assert(metrics.baseline == 0);
      width += metrics.width;
      ascent = max(ascent, metrics.ascent);
      descent = max(descent, metrics.descent);
    }
    return LineMetrics(width: width, ascent: ascent, descent: descent);
  }
}
