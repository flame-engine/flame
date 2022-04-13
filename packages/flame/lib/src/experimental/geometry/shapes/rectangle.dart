import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../../../game/transform2d.dart';
import 'shape.dart';

/// An axis-aligned rectangle.
///
/// This is similar to dart:ui's [Rect], except that this class is mutable, and
/// conforms to the [Shape] API.
class Rectangle extends Shape {
  Rectangle.fromLTRB(this._left, this._top, this._right, this._bottom)
      : assert(_left < _right && _top < _bottom);

  factory Rectangle.fromPoints(Vector2 a, Vector2 b) => Rectangle.fromLTRB(
        min(a.x, b.x),
        min(a.y, b.y),
        max(a.x, b.x),
        max(a.y, b.y),
      );

  factory Rectangle.fromRect(Rect rect) =>
      Rectangle.fromLTRB(rect.left, rect.top, rect.right, rect.bottom);

  double _left;
  double _top;
  double _right;
  double _bottom;

  @override
  Aabb2 calculateAabb() {
    return Aabb2.minMax(Vector2(_left, _top), Vector2(_right, _bottom));
  }

  @override
  bool get isConvex => true;

  @override
  Vector2 get center => Vector2((_left + _right) / 2, (_top + _bottom) / 2);

  @override
  double get perimeter => 2 * ((_right - _left) + (_bottom - _top));

  @override
  Path asPath() {
    return Path()..addRect(Rect.fromLTRB(_left, _top, _right, _bottom));
  }

  /// Returns true if [point] is inside the rectangle.
  ///
  /// The top and left edges are inclusive, while the bottom and right are
  /// exclusive.
  @override
  bool containsPoint(Vector2 point) {
    return point.x >= _left &&
        point.x < _right &&
        point.y >= _top &&
        point.y < _bottom;
  }

  @override
  Shape project(Transform2D transform) {
    if (transform.isAxisAligned) {
      final newMin = transform.localToGlobal(Vector2(_left, _top));
      final newMax = transform.localToGlobal(Vector2(_right, _bottom));
      return Rectangle.fromPoints(newMin, newMax);
    }
    throw UnimplementedError();
  }

  @override
  void move(Vector2 offset) {
    _left += offset.x;
    _right += offset.x;
    _top += offset.y;
    _bottom += offset.y;
    super.move(offset);
  }

  @override
  String toString() => 'Rectangle([$_left, $_top], [$_right, $_bottom])';
}
