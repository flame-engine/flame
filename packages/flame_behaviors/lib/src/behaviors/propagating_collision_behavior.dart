import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

/// {@template collision_behavior}
/// This behavior is used for collision between entities. The
/// [PropagatingCollisionBehavior] propagates the collision to this behavior if
/// the entity that is colliding with the [Parent] is an instance of [Collider].
/// {@endtemplate}
abstract class CollisionBehavior<
  Collider extends Component,
  Parent extends EntityMixin
>
    extends Behavior<Parent> {
  /// {@macro collision_behavior}
  CollisionBehavior({
    super.children,
    super.priority,
    super.key,
  });

  /// Check if the given component is an instance of [Collider].
  bool isValid(Component c) => c is Collider;

  /// Called when the entity collides with [Collider].
  void onCollision(Set<Vector2> intersectionPoints, Collider other) {}

  /// Called when the entity starts to collides with [Collider].
  void onCollisionStart(Set<Vector2> intersectionPoints, Collider other) {}

  /// Called when the entity stops to collides with [Collider].
  void onCollisionEnd(Collider other) {}

  /// Whether the object is currently colliding with another [Collider] or not.
  bool get isColliding {
    final propagatingCollisionBehavior =
        parent.findBehavior<PropagatingCollisionBehavior>();

    return propagatingCollisionBehavior.activeCollisions
        .map(propagatingCollisionBehavior.findEntity)
        .whereType<Collider>()
        .isNotEmpty;
  }
}

/// {@template propagating_collision_behavior}
/// This behavior is used to handle collisions between entities and propagates
/// the collision through to any [CollisionBehavior]s that are attached to the
/// entity.
///
/// The [CollisionBehavior]s are filtered by the [CollisionBehavior.isValid]
/// method by checking if the colliding entity is valid for the given behavior
/// and if the colliding entity is valid the [CollisionBehavior.onCollision] is
/// called.
///
/// This allows for strongly typed collision detection. Without having to add
/// multiple collision behaviors for different types of entities or adding more
/// logic to a single collision detection behavior.
///
/// If you have an entity that does not require any [CollisionBehavior]s of its
/// own, you can just add the hitbox directly to the entity's children.
/// Any other entity that has a [CollisionBehavior] for that entity attached
/// will then be able to collide with it.
///
/// **Note**: This behavior can also be used for collisions between entities
/// and non-entity components, by passing the component's type as the
/// `Collider` to the [CollisionBehavior].
///
/// The parent to which this behavior is added should be a [PositionComponent]
/// that uses the [EntityMixin]. Flame behaviors comes with the
/// [PositionedEntity] which does exactly that but any kind of position
/// component will work.
/// {@endtemplate}
class PropagatingCollisionBehavior<Parent extends EntityMixin>
    extends Behavior<Parent>
    with CollisionCallbacks {
  /// {@macro propagating_collision_behavior}
  PropagatingCollisionBehavior(
    this._hitbox, {
    super.priority,
    super.key,
  }) : super(children: [_hitbox]);

  final ShapeHitbox _hitbox;

  @override
  @mustCallSuper
  void onMount() {
    assert(parent is PositionComponent, 'parent must be a PositionComponent');
    super.onMount();
  }

  @override
  void onLoad() {
    _hitbox
      ..onCollisionCallback = onCollision
      ..onCollisionStartCallback = onCollisionStart
      ..onCollisionEndCallback = onCollisionEnd;
    parent.children.register<CollisionBehavior>();
    _propagateToBehaviors = parent.children.query<CollisionBehavior>();
  }

  /// List of [CollisionBehavior]s to which it can propagate to.
  Iterable<CollisionBehavior> _propagateToBehaviors = [];

  /// Tries to find the entity that is colliding with the given entity.
  ///
  /// It will check if the parent is either a [PropagatingCollisionBehavior]
  /// or a [Entity]. If it is neither, it will return [other] or null if [other]
  /// is not mounted.
  Component? findEntity(PositionComponent other) {
    final parent = other.parent;
    if (!other.isMounted) {
      return null;
    }

    if (parent is! PropagatingCollisionBehavior && parent is! Entity) {
      if (other is ShapeHitbox) {
        return other.parent;
      }
      return other;
    }

    return parent is Entity
        ? parent
        : (parent as PropagatingCollisionBehavior?)?.parent;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    activeCollisions.add(other);
    final otherEntity = findEntity(other);
    if (otherEntity == null) {
      return;
    }

    for (final behavior in _propagateToBehaviors) {
      if (behavior.isValid(otherEntity)) {
        behavior.onCollisionStart(intersectionPoints, otherEntity);
      }
    }
    return super.onCollisionStart(intersectionPoints, other);
  }

  @override
  @mustCallSuper
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    final otherEntity = findEntity(other);
    if (otherEntity == null) {
      return;
    }

    for (final behavior in _propagateToBehaviors) {
      if (behavior.isValid(otherEntity)) {
        behavior.onCollision(intersectionPoints, otherEntity);
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    activeCollisions.remove(other);
    final otherEntity = findEntity(other);
    if (otherEntity == null) {
      return;
    }

    for (final behavior in _propagateToBehaviors) {
      if (behavior.isValid(otherEntity)) {
        behavior.onCollisionEnd(otherEntity);
      }
    }
    return super.onCollisionEnd(other);
  }
}
