import 'dart:ui' hide LineMetrics;

import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/common/text_line.dart';
import 'package:flame/src/text/inline/text_element.dart';

/// An [TextElement] containing other [TextElement]s inside.
///
/// This class allows forming a tree of [TextElement]s, placing different
/// kinds of [TextElement]s next to each other.
class GroupTextElement extends TextElement {
  GroupTextElement(this.children, {this.spacing = 0});

  final List<TextElement> children;

  /// Extra distance to insert between the child text elements.
  final double spacing;

  @override
  final List<_InlineTextGroupLine> lines = [];

  /// Index of the child currently being laid out.
  int _currentIndex = 0;

  @override
  LayoutResult layOutNextLine(LineMetrics bounds) {
    final line = _InlineTextGroupLine(
      LineMetrics(left: bounds.left, baseline: bounds.baseline),
    );
    lines.add(line);
    while (_currentIndex < children.length) {
      final child = children[_currentIndex];
      final childLayoutResult = child.layOutNextLine(bounds);
      if (childLayoutResult == LayoutResult.didNotAdvance) {
        if (line.metrics.width == 0) {
          lines.removeLast();
          return LayoutResult.didNotAdvance;
        } else {
          return LayoutResult.unfinished;
        }
      }
      line.addChild(child.lastLaidOutLine);
      if (childLayoutResult == LayoutResult.unfinished) {
        return LayoutResult.unfinished;
      } else {
        bounds.setLeftEdge(line.metrics.right + spacing);
        _currentIndex++;
      }
    }
    return LayoutResult.done;
  }

  @override
  void render(Canvas canvas) {
    children.forEach((e) => e.render(canvas));
  }

  @override
  void resetLayout() {
    _currentIndex = 0;
    lines.clear();
    children.forEach((e) => e.resetLayout());
  }
}

class _InlineTextGroupLine implements TextLine {
  _InlineTextGroupLine(this.metrics);

  @override
  final LineMetrics metrics;

  final List<TextLine> _children = [];

  void addChild(TextLine line) {
    metrics.append(line.metrics);
    _children.add(line);
  }

  @override
  void translate(double dx, double dy) {
    _children.forEach((line) => line.translate(dx, dy));
  }
}
