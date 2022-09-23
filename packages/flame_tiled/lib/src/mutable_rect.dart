import 'dart:ui' show Rect;

/// A mutable version of [Rect] for tile map animations.
class MutableRect extends Rect {
  /// Construct a rectangle from its left, top, right, and bottom edges.
  MutableRect.fromLTRB(this.left, this.top, this.right, this.bottom)
      : super.fromLTRB(left, top, right, bottom);

  /// Create a new instance from [other].
  factory MutableRect.fromRect(Rect other) =>
      MutableRect.fromLTRB(other.left, other.top, other.right, other.bottom);

  /// The offset of the left edge of this rectangle from the x axis.
  @override
  double left;

  /// The offset of the top edge of this rectangle from the y axis.
  @override
  double top;

  /// The offset of the right edge of this rectangle from the x axis.
  @override
  double right;

  /// The offset of the bottom edge of this rectangle from the y axis.
  @override
  double bottom;

  /// Update with [other]'s dimensions.
  void copy(Rect other) {
    left = other.left;
    top = other.top;
    right = other.right;
    bottom = other.bottom;
  }

  /// Convert to immutable rectangle.
  Rect toRect() => Rect.fromLTRB(left, top, right, bottom);
}
