import 'package:flame/src/text/elements/element.dart';

/// [BlockElement] is the base class for [Element]s with rectangular shape and
/// "block" placement rules.
///
/// Within HTML, this corresponds to elements with `display: block` property,
/// such as `<div>` or `<blockquote>`.
abstract class BlockElement extends Element {
  BlockElement(this.width, this.height);
  double width;
  double height;
}
