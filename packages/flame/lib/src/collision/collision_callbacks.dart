import 'package:meta/meta.dart';

import '../../components.dart';

/// The [CollidableType] is used to determine which other collidables that it
/// should collide with.
enum CollidableType {
  /// Collides with other collidables of type active or passive.
  active,

  /// Collides with other collidables of type active.
  passive,

  /// Will not collide with any other collidables.
  inactive,
}

mixin Collidable<T> {
  Aabb2 get aabb;
  CollidableType collidableType = CollidableType.active;

  Set<T>? _activeCollisions;
  Set<T> get activeCollisions => _activeCollisions ??= {};

  /// Since this is a cheaper calculation than checking towards all shapes, this
  /// check can be done first to see if it even is possible that the shapes can
  /// overlap, since the shapes have to be within the size of the component.
  bool possiblyOverlapping(Collidable other) {
    return aabb.intersectsWithAabb2(other.aabb);
  }

  /// Since this is a cheaper calculation than checking towards all shapes this
  /// check can be done first to see if it even is possible that the shapes can
  /// contain the point, since the shapes have to be within the size of the
  /// component.
  bool possiblyContainsPoint(Vector2 point) => aabb.containsVector2(point);

  Set<Vector2> intersections(T other);

  @mustCallSuper
  void onCollision(Set<Vector2> intersectionPoints, T other) {
    collisionCallback?.call(intersectionPoints, other);
  }

  @mustCallSuper
  void onCollisionStart(Set<Vector2> intersectionPoints, T other) {
    activeCollisions.add(other);
    collisionStartCallback?.call(intersectionPoints, other);
  }

  @mustCallSuper
  void onCollisionEnd(T other) {
    activeCollisions.remove(other);
    collisionEndCallback?.call(other);
  }

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [T].
  CollisionCallback<T>? collisionCallback;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape starts to collide with another [T].
  CollisionCallback<T>? collisionStartCallback;

  /// Assign your own [CollisionEndCallback] if you want a callback when this
  /// shape stops colliding with another [T].
  CollisionEndCallback<T>? collisionEndCallback;
}

typedef CollisionCallback<T> = void Function(
  Set<Vector2> intersectionPoints,
  T other,
);

typedef CollisionEndCallback<T> = void Function(T other);
