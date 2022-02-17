import '../../collision_detection.dart';
import '../../components.dart';

abstract class CollisionDetection<T extends Hitbox<T>> {
  final List<T> items = [];
  late final Broadphase<T> broadphase;

  CollisionDetection({BroadphaseType type = BroadphaseType.sweep}) {
    switch (type) {
      case BroadphaseType.sweep:
        broadphase = Sweep<T>(items);
    }
  }

  void add(T item) => items.add(item);
  void addAll(Iterable<T> items) => items.forEach(add);

  /// Removes the [item] from the collision detection, if you just want
  /// to temporarily inactivate it you can set
  /// `collidableType = CollidableType.inactive;` instead.
  void remove(T item) => items.remove(item);

  /// Removes all [items] from the collision detection, see [remove].
  void removeAll(Iterable<T> items) => items.forEach(remove);

  /// Run collision detection for the current state of [items].
  void run() {
    broadphase.query().forEach((tuple) {
      final itemA = tuple.a;
      final itemB = tuple.b;

      if (itemA.possiblyOverlapping(itemB)) {
        final intersectionPoints = intersections(itemA, itemB);
        if (intersectionPoints.isNotEmpty) {
          if (!itemA.collidingWith(itemB)) {
            handleCollisionStart(intersectionPoints, itemA, itemB);
          }
          handleCollision(intersectionPoints, itemA, itemB);
        } else if (itemA.collidingWith(itemB)) {
          handleCollisionEnd(itemA, itemB);
        }
      }
    });
  }

  /// Check what the intersection points of two items are,
  /// returns an empty list if there are no intersections.
  Set<Vector2> intersections(T itemA, T itemB);
  void handleCollisionStart(Set<Vector2> intersectionPoints, T itemA, T itemB);
  void handleCollision(Set<Vector2> intersectionPoints, T itemA, T itemB);
  void handleCollisionEnd(T itemA, T itemB);
}

/// Check whether any [HitboxShape]s in [items] collide with each other and
/// call their callback methods accordingly.
class StandardCollisionDetection extends CollisionDetection<HitboxShape> {
  StandardCollisionDetection({BroadphaseType type = BroadphaseType.sweep})
      : super(type: type);

  /// Removes the [hitbox] from the collision detection, if you just want
  /// to temporarily inactivate it you can set
  /// `collidableType = CollidableType.inactive;` instead.
  /// This calls [CollisionCallbacks.onCollisionEnd] for [HitboxShape]s and
  /// their hitbox parents if a hitbox that they currently are colliding with is
  /// removed from the game.
  @override
  void remove(HitboxShape hitbox) {
    hitbox.activeCollisions.toList(growable: false).forEach((otherCollidable) {
      handleCollisionEnd(hitbox, otherCollidable);
    });
    super.remove(hitbox);
  }

  /// Check what the intersection points of two collidables are,
  /// returns an empty list if there are no intersections.
  @override
  Set<Vector2> intersections(
    HitboxShape hitboxA,
    HitboxShape hitboxB,
  ) {
    final result = hitboxA.intersections(hitboxB);
    if (result.isNotEmpty) {
      if (!hitboxA.collidingWith(hitboxB)) {
        handleCollisionStart(result, hitboxA, hitboxB);
      }
      handleCollision(result, hitboxA, hitboxB);
    } else if (hitboxA.collidingWith(hitboxB)) {
      handleCollisionEnd(hitboxA, hitboxB);
    }

    return result;
  }

  @override
  void handleCollisionStart(
    Set<Vector2> intersectionPoints,
    HitboxShape hitboxA,
    HitboxShape hitboxB,
  ) {
    hitboxA.onCollisionStart(intersectionPoints, hitboxB);
    hitboxB.onCollisionStart(intersectionPoints, hitboxA);
  }

  @override
  void handleCollision(
    Set<Vector2> intersectionPoints,
    HitboxShape hitboxA,
    HitboxShape hitboxB,
  ) {
    hitboxA.onCollision(intersectionPoints, hitboxB);
    hitboxB.onCollision(intersectionPoints, hitboxA);
  }

  @override
  void handleCollisionEnd(HitboxShape hitboxA, HitboxShape hitboxB) {
    hitboxA.onCollisionEnd(hitboxB);
    hitboxB.onCollisionEnd(hitboxA);
  }
}
