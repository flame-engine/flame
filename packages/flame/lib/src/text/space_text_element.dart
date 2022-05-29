
import 'dart:ui';

import 'package:flame/src/text/inline_text_element.dart';
import 'package:flame/src/text/text_line.dart';

class SpaceTextElement extends InlineTextElement {
  @override
  // TODO: implement isLaidOut
  bool get isLaidOut => throw UnimplementedError();

  @override
  // TODO: implement lastLine
  TextLine get lastLine => throw UnimplementedError();

  @override
  LayoutResult layOutNextLine(double x0, double x1, double baseline) {
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
