import 'dart:ui';

import '../components/position_component.dart';
import '../extensions/vector2.dart';

abstract class Shape {
  // TODO: Is position needed?
  Vector2 position;
  Vector2 size;
  double angle;
  Vector2 center;

  bool containsPoint(Vector2 p);

  void render(Canvas c, Paint paint);
}

mixin HitboxShape on Shape {
  PositionComponent component;

  @override
  Vector2 get position => component.position;

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