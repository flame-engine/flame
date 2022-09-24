import 'package:flame/src/text/common/text_line.dart';
import 'package:flame/src/text/elements/element.dart';

/// [TextElement] is the base class describing a span of text that has *inline*
/// placement rules.
///
/// Concrete implementations of this class must know how to perform own layout
/// (i.e. determine the exact placement and size of each internal piece), and
/// then render on a canvas afterwards.
abstract class TextElement extends Element {
  TextLine get lastLine;
}
