import 'dart:ui';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'shape_intersections.dart' as intersection_system;

abstract class Shape {
  Vector2 position = Vector2.zero();
  Vector2 size;
  double angle;

  Vector2 origin = Vector2.zero();
  Vector2 parentSize = Vector2.zero();

  /// Get the relative top left position regardless of the anchor and angle
  Vector2 get topLeftPosition => Anchor.center.translate(position, size);
  Vector2 get center => topLeftPosition + size / 2;

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
  Vector2 get origin => component.absoluteTopLeftPosition + component.size / 2;

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
