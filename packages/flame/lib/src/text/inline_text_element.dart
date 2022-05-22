import 'dart:ui';

import 'package:flame/src/text/text_line.dart';

/// A span of text that has "inline" placement rules.
///
/// An inline text can potentially span multiple lines, be adjacent to other
/// [InlineTextElement]s, or contain other [InlineTextElement]s inside.
///
/// An [InlineTextElement] can be laid out, and then rendered on a canvas.
abstract class InlineTextElement {
  bool get isLaidOut;

  void resetLayout();

  int get numLinesLaidOut;

  TextLine line(int line);

  LayoutStatus layOutNextLine(double x0, double x1, double baseline);

  void render(Canvas canvas);
}

enum LayoutStatus {
  didNotAdvance,
  unfinished,
  done,
}
