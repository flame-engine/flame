import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:meta/meta.dart';

/// The [CollisionType] is used to determine which other hitboxes that it
/// should collide with.
enum CollisionType {
  /// Collides with other hitboxes of type active or passive.
  active,

  /// Collides with other hitboxes of type active.
  passive,

  /// Will not collide with any other hitboxes.
  inactive,
}

/// The [GenericCollisionCallbacks] mixin can be used to get callbacks from the
/// collision detection system, potentially without using the Flame component
/// system.
/// The default implementation used with FCS is [CollisionCallbacks].
/// The generic type [T] here is the type of the object that has the hitboxes
/// are attached to, for example it is [PositionComponent] in the
/// [StandardCollisionDetection].
mixin GenericCollisionCallbacks<T> {
  Set<T>? _activeCollisions;

  /// The objects that the object is currently colliding with.
  Set<T> get activeCollisions => _activeCollisions ??= {};

  /// Whether the object is currently colliding or not.
  bool get isColliding {
    return _activeCollisions?.isNotEmpty ?? false;
  }

  /// Whether the object is colliding with [other] or not.
  bool collidingWith(T other) {
    return _activeCollisions?.contains(other) ?? false;
  }

  /// [onCollision] is called in every tick when this object is colliding with
  /// [other].
  @mustCallSuper
  void onCollision(Set<Vector2> intersectionPoints, T other) {
    onCollisionCallback?.call(intersectionPoints, other);
  }

  /// [onCollisionStart] is called in the first tick when this object starts
  /// colliding with [other].
  @mustCallSuper
  void onCollisionStart(Set<Vector2> intersectionPoints, T other) {
    activeCollisions.add(other);
    onCollisionStartCallback?.call(intersectionPoints, other);
  }

  /// [onCollisionEnd] is called once when this object has stopped colliding
  /// with [other].
  @mustCallSuper
  void onCollisionEnd(T other) {
    activeCollisions.remove(other);
    onCollisionEndCallback?.call(other);
  }

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [T].
  CollisionCallback<T>? onCollisionCallback;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape starts to collide with another [T].
  CollisionCallback<T>? onCollisionStartCallback;

  /// Assign your own [CollisionEndCallback] if you want a callback when this
  /// shape stops colliding with another [T].
  CollisionEndCallback<T>? onCollisionEndCallback;
}

mixin CollisionCallbacks on Component
    implements GenericCollisionCallbacks<PositionComponent> {
  @override
  Set<PositionComponent>? _activeCollisions;
  @override
  Set<PositionComponent> get activeCollisions => _activeCollisions ??= {};

  @override
  bool get isColliding {
    return _activeCollisions != null && _activeCollisions!.isNotEmpty;
  }

  @override
  bool collidingWith(PositionComponent other) {
    return _activeCollisions != null && activeCollisions.contains(other);
  }

  @override
  @mustCallSuper
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    onCollisionCallback?.call(intersectionPoints, other);
  }

  @override
  @mustCallSuper
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    activeCollisions.add(other);
    onCollisionStartCallback?.call(intersectionPoints, other);
  }

  @override
  @mustCallSuper
  void onCollisionEnd(PositionComponent other) {
    activeCollisions.remove(other);
    onCollisionEndCallback?.call(other);
  }

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [PositionComponent].
  @override
  CollisionCallback<PositionComponent>? onCollisionCallback;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape starts to collide with another [PositionComponent].
  @override
  CollisionCallback<PositionComponent>? onCollisionStartCallback;

  /// Assign your own [CollisionEndCallback] if you want a callback when this
  /// shape stops colliding with another [PositionComponent].
  @override
  CollisionEndCallback<PositionComponent>? onCollisionEndCallback;
}

/// Can be used used to implement an `onCollisionCallback` or an
/// `onCollisionStartCallback`.
typedef CollisionCallback<T> = void Function(
  Set<Vector2> intersectionPoints,
  T other,
);

/// Can be used used to implement an `onCollisionEndCallback`.
typedef CollisionEndCallback<T> = void Function(T other);
