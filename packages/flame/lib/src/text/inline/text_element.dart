import 'dart:ui' hide LineMetrics;

import 'package:flame/src/text/common/text_line.dart';

/// [TextElement] is the base class describing a span of text that has *inline*
/// placement rules.
///
/// Concrete implementations of this class must know how to perform own layout
/// (i.e. determine the exact placement and size of each internal piece), and
/// then render on a canvas afterwards.
abstract class TextElement {
  TextLine get lastLine;

  /// Renders the text on the [canvas], at positions determined during the
  /// layout.
  ///
  /// This method should only be invoked after the text was laid out.
  ///
  /// In order to render the text at a different location, consider applying a
  /// translation transform to the canvas.
  void render(Canvas canvas);
}
