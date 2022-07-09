
import 'package:flame/src/text/elements/element.dart';

/// Base class for an element with a rectangular shape and "block" placement
/// rules.
abstract class BlockElement extends Element {
  BlockElement(this.width, this.height);
  double width;
  double height;
}
