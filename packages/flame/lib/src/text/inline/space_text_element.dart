import 'dart:ui';

import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:flame/src/text/text_line.dart';

class SpaceTextElement extends TextElement {
  @override
  bool get isLaidOut => throw UnimplementedError();

  @override
  TextLine get lastLine => throw UnimplementedError();

  @override
  LayoutResult layOutNextLine(LineMetrics bounds) {
    throw UnimplementedError();
  }

  @override
  Iterable<TextLine> get lines => throw UnimplementedError();

  @override
  void render(Canvas canvas) {}

  @override
  void resetLayout() {
  }
}
