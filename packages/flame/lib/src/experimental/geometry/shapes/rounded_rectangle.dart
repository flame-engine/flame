import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../../game/transform2d.dart';
import 'shape.dart';

/// An axis-aligned rectangle with rounded corners.
///
/// Unlike [RRect] from dart:ui, this shape has corners of equal radii.
class RoundedRectangle extends Shape {
  RoundedRectangle.fromLTRBR(
    this._left,
    this._top,
    this._right,
    this._bottom,
    this._radius,
  )   : assert(_radius > 0),
        assert(_right - _left >= 2 * _radius && _bottom - _top >= 2 * _radius);

  factory RoundedRectangle.fromPoints(Vector2 a, Vector2 b, double radius) =>
      RoundedRectangle.fromLTRBR(
        min(a.x, b.x),
        min(a.y, b.y),
        max(a.x, b.x),
        max(a.y, b.y),
        radius,
      );

  factory RoundedRectangle.fromRRect(RRect rrect) {
    final radius = rrect.brRadiusX;
    assert(
      rrect.blRadiusX == radius &&
          rrect.brRadiusX == radius &&
          rrect.tlRadiusX == radius &&
          rrect.trRadiusX == radius &&
          rrect.blRadiusY == radius &&
          rrect.brRadiusY == radius &&
          rrect.tlRadiusY == radius &&
          rrect.trRadiusY == radius,
    );
    return RoundedRectangle.fromLTRBR(
      rrect.left,
      rrect.top,
      rrect.right,
      rrect.bottom,
      radius,
    );
  }

  double _left;
  double _top;
  double _right;
  double _bottom;
  double _radius;

  @override
  bool get isConvex => true;

  @override
  double get perimeter =>
      (tau - 8) * _radius + 2 * ((_right - _left) + (_bottom - _top));

  @override
  Vector2 get center => Vector2((_left + _right) / 2, (_top + _bottom) / 2);

  @override
  Aabb2 get aabb => _aabb ??= _calculateAabb();
  Aabb2? _aabb;

  Aabb2 _calculateAabb() =>
      Aabb2.minMax(Vector2(_left, _top), Vector2(_right, _bottom));

  /// Converts this shape into an [RRect] from dart:ui.
  RRect asRRect() =>
      RRect.fromLTRBR(_left, _top, _right, _bottom, Radius.circular(_radius));

  @override
  Path asPath() => Path()..addRRect(asRRect());

  @override
  bool containsPoint(Vector2 point) {
    final x0 = point.x;
    final y0 = point.y;
    if (x0 < _left || x0 > _right || y0 < _top || y0 > _bottom) {
      return false;
    }
    final fx = _radius - min(x0 - _left, min(_right - x0, _radius));
    final fy = _radius - min(y0 - _top, min(_bottom - y0, _radius));
    return fx * fx + fy * fy <= _radius * _radius;
  }

  @override
  Shape project(Transform2D transform, [Shape? target]) {
    if (transform.isTranslation) {
      final newMin = transform.localToGlobal(Vector2(_left, _top));
      final newMax = transform.localToGlobal(Vector2(_right, _bottom));
      return RoundedRectangle.fromPoints(newMin, newMax, _radius);
    }
    throw UnimplementedError();
  }

  @override
  void move(Vector2 offset) {
    throw UnimplementedError();
  }

  @override
  Vector2 support(Vector2 direction) {
    final result = direction.normalized()..length = _radius;
    result.x += direction.x >= 0 ? _right - _radius : _left + _radius;
    result.y += direction.y >= 0 ? _bottom - _radius : _top + _radius;
    return result;
  }

  @override
  String toString() =>
      'RoundedRectangle([$_left, $_top], [$_right, $_bottom], $_radius)';
}

@internal
const tau = Transform2D.tau; // 2π
