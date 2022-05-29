
import 'dart:ui';

import 'package:flame/src/text/inline_text_element.dart';
import 'package:flame/src/text/text_line.dart';

/// An [InlineTextElement] containing other [InlineTextElement]s inside.
///
/// This class allows forming a tree of [InlineTextElement]s, placing different
/// kinds of [InlineTextElement]s next to each other.
class InlineTextGroup extends InlineTextElement {
  InlineTextGroup(this._children);

  final List<InlineTextElement> _children;
  int _currentElement = 0;

  @override
  bool get isLaidOut => _currentElement == _children.length;

  @override
  LayoutResult layOutNextLine(double x0, double x1, double baseline) {
    // TODO: implement layOutNextLine
    throw UnimplementedError();
  }

  @override
  TextLine line(int line) {
    // TODO: implement line
    throw UnimplementedError();
  }

  @override
  // TODO: implement numLinesLaidOut
  int get numLinesLaidOut => throw UnimplementedError();

  @override
  void render(Canvas canvas) {
    // TODO: implement render
  }

  @override
  void resetLayout() {
    // TODO: implement resetLayout
  }
}
