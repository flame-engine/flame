import 'dart:ui';

import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/src/text/common/line_metrics.dart';
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
          baseline: 0,
          width: width,
          ascent: baseline,
          descent: height - baseline,
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
    metrics.baseline = y0;
    return LayoutResult.done;
  }

  @override
  void translate(double dx, double dy) {
    metrics.left += dx;
    metrics.baseline += dx;
  }

  @override
  void render(Canvas canvas) {}

  @override
  void resetLayout() {
    metrics.left = 0;
    metrics.baseline = 0;
  }
}
