import 'dart:math';
import 'dart:ui';

import 'package:flame/geometry.dart';
import 'package:flame/math.dart';
import 'package:flame/src/experimental/geometry/shapes/shape.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:flame/src/math/random_fallback.dart';

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
    return (_tmpResult
              ..setFrom(point)
              ..sub(_center))
            .length2 <=
        _radius * _radius;
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

  static final Vector2 _tmpResult = Vector2.zero();

  @override
  Vector2 nearestPoint(Vector2 point) {
    if (_radius == 0) {
      return _center;
    }
    return _tmpResult
      ..setFrom(point)
      ..sub(_center)
      ..length = _radius
      ..add(_center);
  }

  @override
  Vector2 randomPoint({Random? random, bool within = true}) {
    final randomGenerator = random ?? randomFallback;
    final theta = randomGenerator.nextDouble() * tau;
    final radius = within ? randomGenerator.nextDouble() * _radius : _radius;
    final x = radius * cos(theta);
    final y = radius * sin(theta);

    return Vector2(_center.x + x, _center.y + y);
  }

  @override
  String toString() => 'Circle([${_center.x}, ${_center.y}], $_radius)';

  /// Tries to create a Circle that intersects the 3 points, if it exists.
  ///
  /// As long as the points are not co-linear, there is always exactly one
  /// circle intersecting all 3 points.
  static Circle? fromPoints(Vector2 p1, Vector2 p2, Vector2 p3) {
    final offset = p2.length2;
    final bc = (p1.length2 - offset) / 2.0;
    final cd = (offset - p3.length2) / 2.0;
    final det = (p1.x - p2.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p2.y);
    if (det == 0) {
      return null;
    }

    final centerX = (bc * (p2.y - p3.y) - cd * (p1.y - p2.y)) / det;
    final centerY = (cd * (p1.x - p2.x) - bc * (p2.x - p3.x)) / det;
    final radius = sqrt(pow(p2.x - centerX, 2) + pow(p2.y - centerY, 2));

    return Circle(Vector2(centerX, centerY), radius);
  }
}
