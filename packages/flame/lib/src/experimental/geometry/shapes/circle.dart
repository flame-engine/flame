import 'dart:ui';

import 'package:flame/src/experimental/geometry/shapes/shape.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:meta/meta.dart';

/// The circle with a given [center] and a [radius].
///
/// A circle's radius cannot be negative, but it can be zero.
///
/// A circle transforms into a circle under any conformal transformation, i.e.
/// a [Transform2D] that contains translations, rotations, and uniform scaling.
/// Under a generic projection, a circle would turn into an ellipse, however,
/// this is currently not implemented.
class Circle extends Shape {
  Circle(Vector2 center, double radius)
      : assert(radius >= 0, 'Radius cannot be negative: $radius'),
        _center = center.clone(),
        _radius = radius;

  @override
  Vector2 get center => _center;
  final Vector2 _center;

  double get radius => _radius;
  double _radius;

  @override
  Aabb2 get aabb => _aabb ??= _calculateAabb();
  Aabb2? _aabb;

  Aabb2 _calculateAabb() {
    return Aabb2.centerAndHalfExtents(_center, Vector2.all(_radius));
  }

  @override
  bool get isConvex => true;

  @override
  double get perimeter => _radius * tau;

  @override
  Path asPath() {
    final center = _center.toOffset();
    return Path()..addOval(Rect.fromCircle(center: center, radius: _radius));
  }

  @override
  bool containsPoint(Vector2 point) {
    return (point - _center).length2 <= _radius * _radius;
  }

  @override
  Shape project(Transform2D transform, [Shape? target]) {
    if (transform.isConformal) {
      final newCenter = transform.localToGlobal(_center);
      final newRadius = transform.scale.x.abs() * _radius;
      if (target is Circle) {
        target._center.setFrom(newCenter);
        target._radius = newRadius;
        _aabb = null;
        return target;
      } else {
        return Circle(newCenter, newRadius);
      }
    }
    throw UnimplementedError();
  }

  @override
  void move(Vector2 offset) {
    _center.add(offset);
    _aabb?.min.add(offset);
    _aabb?.max.add(offset);
  }

  @override
  Vector2 support(Vector2 direction) {
    return direction.normalized()
      ..scale(_radius)
      ..add(_center);
  }

  @override
  String toString() => 'Circle([${_center.x}, ${_center.y}], $_radius)';
}

@internal
const tau = Transform2D.tau; // 2π
