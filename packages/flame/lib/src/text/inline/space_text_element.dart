
import 'dart:ui';

import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:flame/src/text/text_line.dart';

class SpaceTextElement extends TextElement {
  @override
  // TODO: implement isLaidOut
  bool get isLaidOut => throw UnimplementedError();

  @override
  // TODO: implement lastLine
  TextLine get lastLine => throw UnimplementedError();

  @override
  LayoutResult layOutNextLine(LineMetrics bounds) {
    // TODO: implement layOutNextLine
    throw UnimplementedError();
  }

  @override
  // TODO: implement lines
  Iterable<TextLine> get lines => throw UnimplementedError();

  @override
  void render(Canvas canvas) {}

  @override
  void resetLayout() {
    // TODO: implement resetLayout
  }

}
