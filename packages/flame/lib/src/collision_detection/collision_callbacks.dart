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

// TODO(spydon): Don't keep this as T, or create another one
mixin CollisionCallbacks<T> {
  Set<T>? _activeCollisions;
  Set<T> get activeCollisions => _activeCollisions ??= {};

  bool get isColliding {
    return _activeCollisions != null && _activeCollisions!.isNotEmpty;
  }

  bool collidingWith(T other) {
    return _activeCollisions != null && activeCollisions.contains(other);
  }

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
