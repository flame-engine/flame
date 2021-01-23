import 'dart:ui';

import '../components/position_component.dart';
import '../extensions/vector2.dart';
import 'shape_intersections.dart' as intersection_system;

abstract class Shape {
  Vector2 center;
  Vector2 size;
  double angle;

  Shape({this.center, this.size, this.angle});

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
  Vector2 get size => component.size;

  @override
  double get angle => component.angle;

  @override
  Vector2 get center => component.center;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [HitboxShape]
  CollisionCallback collisionCallback = emptyCollisionCallback;
}

typedef CollisionCallback = Function(Set<Vector2> points, HitboxShape other);
final CollisionCallback emptyCollisionCallback = (_a, _b) {};
