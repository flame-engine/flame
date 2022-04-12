import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../../game/transform2d.dart';
import 'shape.dart';

/// An axis-aligned rectangle.
@immutable
class Rectangle extends Shape {
  Rectangle.fromLTRB(double left, double top, double right, double bottom)
      : _min = Vector2(left, top),
        _max = Vector2(right, bottom),
        assert(left < right && top < bottom);

  factory Rectangle.fromPoints(Vector2 a, Vector2 b) => Rectangle.fromLTRB(
        min(a.x, b.x),
        min(a.y, b.y),
        max(a.x, b.x),
        max(a.y, b.y),
      );

  factory Rectangle.fromRect(Rect rect) =>
      Rectangle.fromLTRB(rect.left, rect.top, rect.right, rect.bottom);

  final Vector2 _min;
  final Vector2 _max;

  @override
  bool get isClosed => true;

  @override
  bool get isConvex => true;

  @override
  Vector2 get center => (_min + _max)..scaled(0.5);

  @override
  double get perimeter => 2 * ((_max.x - _min.x) + (_max.y - _min.y));

  @override
  Aabb2 get aabb => Aabb2.minMax(_min, _max);

  @override
  Path asPath() {
    return Path()..addRect(Rect.fromLTRB(_min.x, _min.y, _max.x, _max.y));
  }

  /// Returns true if [point] is inside the rectangle.
  ///
  /// The top and left edges are inclusive, while the bottom and right are
  /// exclusive. The [epsilon] parameter is ignored.
  @override
  bool containsPoint(Vector2 point, {double epsilon = 0.00001}) {
    return point.x >= _min.x &&
        point.x < _max.x &&
        point.y >= _min.y &&
        point.y < _max.y;
  }

  @override
  Shape project(Transform2D transform) {
    if (transform.isAxisAligned) {
      final newMin = transform.localToGlobal(_min);
      final newMax = transform.localToGlobal(_max);
      return Rectangle.fromPoints(newMin, newMax);
    }
    throw UnimplementedError();
  }

  @override
  bool operator ==(Object other) =>
      other is Rectangle && _min == other._min && _max == other._max;

  @override
  int get hashCode => hashValues(_min, _max);

  @override
  String toString() =>
      'Rectangle([${_min.x}, ${_min.y}], [${_max.x}, ${_max.y}])';
}
