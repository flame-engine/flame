import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../../game/transform2d.dart';
import 'shape.dart';

/// An axis-aligned rectangle with rounded corners.
///
/// Unlike [RRect] from dart:ui, this shape has corners of equal radii.
@immutable
class RoundedRectangle extends Shape {
  RoundedRectangle.fromLTRBR(
    double left,
    double top,
    double right,
    double bottom,
    double radius,
  )   : _min = Vector2(left, top),
        _max = Vector2(right, bottom),
        _radius = radius,
        assert(radius > 0),
        assert(right - left >= 2 * radius && bottom - top >= 2 * radius);

  factory RoundedRectangle.fromPoints(Vector2 a, Vector2 b, double radius) =>
      RoundedRectangle.fromLTRBR(
        min(a.x, b.x),
        min(a.y, b.y),
        max(a.x, b.x),
        max(a.y, b.y),
        radius,
      );

  factory RoundedRectangle.fromRRect(RRect rrect) {
    final r = rrect.brRadiusX;
    assert(
      rrect.blRadiusX == r &&
          rrect.brRadiusX == r &&
          rrect.tlRadiusX == r &&
          rrect.trRadiusX == r &&
          rrect.blRadiusY == r &&
          rrect.brRadiusY == r &&
          rrect.tlRadiusY == r &&
          rrect.trRadiusY == r,
    );
    return RoundedRectangle.fromLTRBR(
      rrect.left,
      rrect.top,
      rrect.right,
      rrect.bottom,
      r,
    );
  }

  final Vector2 _min;
  final Vector2 _max;
  final double _radius;
  static const tau = Transform2D.tau; // 2π

  @override
  bool get isClosed => true;

  @override
  bool get isConvex => true;

  @override
  double get perimeter =>
      (tau - 8) * _radius + 2 * ((_max.x - _min.x) + (_max.y - _min.y));

  @override
  Vector2 get center => (_min + _max)..scaled(0.5);

  @override
  Aabb2 get aabb => Aabb2.minMax(_min, _max);

  RRect asRRect() {
    return RRect.fromLTRBR(
      _min.x,
      _min.y,
      _max.x,
      _max.y,
      Radius.circular(_radius),
    );
  }

  @override
  Path asPath() => Path()..addRRect(asRRect());

  @override
  bool containsPoint(Vector2 point) {
    if (point.x < _min.x || point.x > _max.x) {
      return false;
    }
    final fx = _radius - min(point.x - _min.x, min(_max.x - point.x, _radius));
    final fy = _radius - min(point.y - _min.y, min(_max.y - point.y, _radius));
    return fx * fx + fy * fy <= _radius * _radius;
  }

  @override
  Shape project(Transform2D transform) {
    if (transform.isTranslation) {
      final newMin = transform.localToGlobal(_min);
      final newMax = transform.localToGlobal(_max);
      return RoundedRectangle.fromPoints(newMin, newMax, _radius);
    }
    throw UnimplementedError();
  }

  @override
  bool operator ==(Object other) =>
      other is RoundedRectangle &&
      _min == other._min &&
      _max == other._max &&
      _radius == other._radius;

  @override
  int get hashCode => hashValues(_min, _max, _radius);

  @override
  String toString() {
    return 'RoundedRectangle([${_min.x}, ${_min.y}], '
        '[${_max.x}, ${_max.y}], $_radius)';
  }
}
