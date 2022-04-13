import 'dart:ui';

import 'package:meta/meta.dart';

import '../../../extensions/vector2.dart';
import '../../../game/transform2d.dart';
import 'shape.dart';

/// The circle with a given [center] and a [radius].
///
/// A circle must have a positive (non-zero) radius.
class Circle extends Shape {
  Circle(Vector2 center, double radius)
      : assert(radius > 0, 'Radius must be positive: $radius'),
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
      } else {
        return Circle(newCenter, newRadius);
      }
    }
    throw UnimplementedError();
  }

  @override
  void move(Vector2 offset) {
    _center.add(offset);
    if (_aabb != null) {
      _aabb!.min.add(offset);
      _aabb!.max.add(offset);
    }
  }

  @override
  String toString() => 'Circle([${_center.x}, ${_center.y}], $_radius)';
}

@internal
const tau = Transform2D.tau; // 2π
