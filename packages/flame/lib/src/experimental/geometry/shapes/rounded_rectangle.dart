import 'dart:math';
import 'dart:ui';

import 'package:flame/src/experimental/geometry/shapes/shape.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// An axis-aligned rectangle with rounded corners.
///
/// The rounded parts of the rectangle are symmetrical in x- and y-directions,
/// and across all corners.
class RoundedRectangle extends Shape {
  /// Constructs a [RoundedRectangle] with left, top, right and bottom edges,
  /// and the given radius.
  ///
  /// If the edges are given in the wrong order (e.g. `left` is to the right
  /// from `right`), then they will be swapped.
  ///
  /// The radius cannot be negative. At the same time, if the radius is too big,
  /// it will be reduced so that the rounded edge can fit inside the rectangle.
  /// In other words, the radius will be adjusted to not exceed the half-width
  /// or half-height of the rectangle.
  RoundedRectangle.fromLTRBR(
    this._left,
    this._top,
    this._right,
    this._bottom,
    this._radius,
  ) : assert(_radius >= 0, 'Radius cannot be negative: $_radius') {
    if (_left > _right) {
      final tmp = _left;
      _left = _right;
      _right = tmp;
    }
    if (_top > _bottom) {
      final tmp = _top;
      _top = _bottom;
      _bottom = tmp;
    }
    if (_radius > (_right - _left) / 2) {
      _radius = (_right - _left) / 2;
    }
    if (_radius > (_bottom - _top) / 2) {
      _radius = (_bottom - _top) / 2;
    }
  }

  factory RoundedRectangle.fromPoints(Vector2 a, Vector2 b, double radius) =>
      RoundedRectangle.fromLTRBR(a.x, a.y, b.x, b.y, radius);

  /// Constructs a [RoundedRectangle] from ui's [RRect].
  ///
  /// All corners of the `rrect` must have the same circular radii.
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
      'Unequal radii in the $rrect',
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

  double get left => _left;
  double get right => _right;
  double get top => _top;
  double get bottom => _bottom;
  double get radius => _radius;
  double get width => _right - _left;
  double get height => _bottom - _top;

  @override
  bool get isConvex => true;

  @override
  double get perimeter => (tau - 8) * _radius + 2 * (width + height);

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
    if (transform.isAxisAligned && transform.isConformal) {
      final v1 = transform.localToGlobal(Vector2(_left, _top));
      final v2 = transform.localToGlobal(Vector2(_right, _bottom));
      final newLeft = min(v1.x, v2.x);
      final newRight = max(v1.x, v2.x);
      final newTop = min(v1.y, v2.y);
      final newBottom = max(v1.y, v2.y);
      final newRadius = transform.scale.x.abs() * _radius;
      if (target is RoundedRectangle) {
        target._left = newLeft;
        target._right = newRight;
        target._top = newTop;
        target._bottom = newBottom;
        target._radius = newRadius;
        target._aabb = null;
        return target;
      } else {
        return RoundedRectangle.fromLTRBR(
          newLeft,
          newTop,
          newRight,
          newBottom,
          newRadius,
        );
      }
    }
    throw UnimplementedError();
  }

  @override
  void move(Vector2 offset) {
    _left += offset.x;
    _right += offset.x;
    _top += offset.y;
    _bottom += offset.y;
    _aabb?.min.add(offset);
    _aabb?.max.add(offset);
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
