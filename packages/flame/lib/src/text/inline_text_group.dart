import 'dart:math';
import 'dart:ui';

import 'package:flame/src/text/inline_text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:flame/src/text/text_line.dart';

/// An [InlineTextElement] containing other [InlineTextElement]s inside.
///
/// This class allows forming a tree of [InlineTextElement]s, placing different
/// kinds of [InlineTextElement]s next to each other.
class InlineTextGroup extends InlineTextElement {
  InlineTextGroup(this._children);

  final List<InlineTextElement> _children;
  final List<TextLine> _lines = [];
  int _currentIndex = 0;

  @override
  bool get isLaidOut => _currentIndex == _children.length;

  @override
  LayoutResult layOutNextLine(double x0, double x1, double baseline) {
    final metric = LineMetrics(left: x0, baseline: baseline);
    while (!isLaidOut) {
      final child = _children[_currentIndex];
      final result = child.layOutNextLine(metric.right, x1, baseline);
      switch (result) {
        case LayoutResult.didNotAdvance:
          if (metric.left == metric.right) {
            return LayoutResult.didNotAdvance;
          } else {
            _lines.add(_InlineTextGroupLine(metric));
            return LayoutResult.unfinished;
          }

        case LayoutResult.unfinished:
          _lines.add(_InlineTextGroupLine(metric));
          return LayoutResult.unfinished;

        case LayoutResult.done:
          final lastMetric = child.lastLine.metrics;
          metric.right = lastMetric.right;
          metric.top = min(metric.top, lastMetric.top);
          metric.bottom = max(metric.bottom, lastMetric.bottom);
          _currentIndex++;
          break;
      }
    }
    if (metric.left != metric.right) {
      _lines.add(_InlineTextGroupLine(metric));
    }
    return LayoutResult.done;
  }

  @override
  Iterable<TextLine> get lines => _lines;

  @override
  TextLine get lastLine => _lines.last;

  @override
  int get numLinesLaidOut => _lines.length;

  @override
  void render(Canvas canvas) {
    assert(isLaidOut);
    _children.forEach((e) => e.render(canvas));
  }

  @override
  void resetLayout() {
    _currentIndex = 0;
    _lines.clear();
    _children.forEach((e) => e.resetLayout());
  }
}

class _InlineTextGroupLine implements TextLine {
  _InlineTextGroupLine(this.metrics);

  @override
  final LineMetrics metrics;
}
