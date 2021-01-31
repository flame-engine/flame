import 'dart:ui';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'shape_intersections.dart' as intersection_system;

abstract class Shape {
  // TODO: should be named localPosition or something maybe?
  Vector2 position = Vector2.zero();
  Vector2 size;
  double angle;

  Vector2 parentSize = Vector2.zero();
  Vector2 get absolutePosition => position;

  Shape({
    this.position,
    this.size,
    this.angle = 0,
  }) {
    position ??= Vector2.zero();
  }

  bool containsPoint(Vector2 p);

  void render(Canvas c, Paint paint);

  /// Where this Shape has intersection points with another shape
  Set<Vector2> intersections(Shape other) {
    return intersection_system.intersections(this, other);
  }
}

mixin HitboxShape on Shape {
  PositionComponent component;

  @override
  Vector2 get absolutePosition {
    return component.absoluteTopLeftPosition + component.size / 2 + position;
  }

  @override
  Vector2 get parentSize => component.size;

  @override
  Vector2 get size => component.size;

  @override
  double get angle => component.angle;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [HitboxShape]
  CollisionCallback collisionCallback = emptyCollisionCallback;
}

typedef CollisionCallback = Function(Set<Vector2> points, HitboxShape other);
final CollisionCallback emptyCollisionCallback = (_a, _b) {};
