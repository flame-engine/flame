import 'package:flame/text.dart';

/// [BlockElement] is the base class for [TextElement]s with rectangular shape
/// and "block" placement rules.
///
/// Within HTML, this corresponds to elements with `display: block` property,
/// such as `<div>` or `<blockquote>`.
abstract class BlockElement extends TextElement {
  BlockElement(this.width, this.height);

  final double width;
  final double height;
}
