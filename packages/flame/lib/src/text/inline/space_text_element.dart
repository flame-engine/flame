import 'dart:ui';

import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:flame/src/text/text_line.dart';

/// Text element representing a single space between words.
///
/// The space is treated specially in several regards:
/// - it doesn't render anything;
/// - the space is allowed to "overshoot" the right boundary during layout;
/// - the space can be stretched when justifying text.
class SpaceTextElement extends TextElement implements TextLine {
  SpaceTextElement({
    required double width,
    required double height,
    required double baseline,
  }) : metrics = LineMetrics(
    left: 0,
    right: width,
    top: -baseline,
    bottom: height - baseline,
    baseline: 0,
  );

  @override
  final LineMetrics metrics;

  @override
  bool get isLaidOut => true;

  @override
  TextLine get lastLine => this;

  @override
  Iterable<TextLine> get lines => [this];

  @override
  LayoutResult layOutNextLine(LineMetrics bounds) {
    assert(metrics.left == 0 && metrics.baseline == 0);
    final x0 = bounds.left;
    final y0 = bounds.baseline;
    metrics.left = x0;
    metrics.right += x0;
    metrics.baseline = y0;
    metrics.top += y0;
    metrics.bottom += y0;
    return LayoutResult.done;
  }

  @override
  void translate(double dx, double dy) {
    metrics.left += dx;
    metrics.right += dx;
    metrics.top += dx;
    metrics.bottom += dx;
    metrics.baseline += dx;
  }

  @override
  void render(Canvas canvas) {}

  @override
  void resetLayout() {
    metrics.right -= metrics.left;
    metrics.top -= metrics.baseline;
    metrics.bottom -= metrics.baseline;
    metrics.left = 0;
    metrics.baseline = 0;
  }
}
