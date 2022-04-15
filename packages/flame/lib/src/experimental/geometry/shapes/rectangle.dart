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

  /// Constructs a [Rectangle] from two opposite corners. The points can be in
  /// any disposition to each other.
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

  double get left => _left;
  double get right => _right;
  double get top => _top;
  double get bottom => _bottom;

  @override
  Aabb2 get aabb => _aabb ??= _calculateAabb();
  Aabb2? _aabb;

  Aabb2 _calculateAabb() {
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

  @override
  bool containsPoint(Vector2 point) {
    return point.x >= _left &&
        point.y >= _top &&
        point.x <= _right &&
        point.y <= _bottom;
  }

  @override
  Shape project(Transform2D transform, [Shape? target]) {
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
    if (_aabb != null) {
      _aabb!.min.add(offset);
      _aabb!.max.add(offset);
    }
  }

  @override
  Vector2 support(Vector2 direction) {
    final vx = direction.x >= 0 ? _right : _left;
    final vy = direction.y >= 0 ? _bottom : _top;
    return Vector2(vx, vy);
  }

  @override
  String toString() => 'Rectangle([$_left, $_top], [$_right, $_bottom])';
}
