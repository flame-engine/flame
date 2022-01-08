import '../../components.dart';
import 'broadphase.dart';
import 'collision_callbacks.dart';
import 'sweep.dart';

abstract class CollisionDetection<T extends Collidable<T>> {
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

      final intersectionPoints = intersections(itemA, itemB);
      if (intersectionPoints.isNotEmpty) {
        if (!_hasActiveCollision(itemA, itemB)) {
          _handleCollisionStart(intersectionPoints, itemA, itemB);
        }
        itemA.onCollision(intersectionPoints, itemB);
        itemB.onCollision(intersectionPoints, itemA);
      } else if (_hasActiveCollision(itemA, itemB)) {
        _handleCollisionEnd(itemA, itemB);
      }
    });
  }

  /// Check what the intersection points of two items are,
  /// returns an empty list if there are no intersections.
  Set<Vector2> intersections(T itemA, T itemB);
  bool _hasActiveCollision(T itemA, T itemB);
  void _handleCollisionStart(Set<Vector2> intersectionPoints, T itemA, T itemB);
  void _handleCollisionEnd(T itemA, T itemB);
}

/// Check whether any [HasHitboxes] in [items] collide with each other and
/// call their callback methods accordingly.
class StandardCollisionDetection extends CollisionDetection<HasHitboxes> {
  final Set<int> _shapeHashes = {};

  StandardCollisionDetection({BroadphaseType type = BroadphaseType.sweep})
      : super(type: type);

  /// Removes the [collidable] from the collision detection, if you just want
  /// to temporarily inactivate it you can set
  /// `collidableType = CollidableType.inactive;` instead.
  /// This calls [HasHitboxes.onCollisionEnd] for [HasHitboxes]s and their
  /// children that are removed from the game.
  @override
  void remove(HasHitboxes collidable) {
    collidable.activeCollisions
        .toList(growable: false)
        .forEach((otherCollidable) {
      _handleCollisionEnd(collidable, otherCollidable);
    });
    super.remove(collidable);
  }

  /// Check what the intersection points of two collidables are,
  /// returns an empty list if there are no intersections.
  @override
  Set<Vector2> intersections(
    HasHitboxes collidableA,
    HasHitboxes collidableB,
  ) {
    final result = <Vector2>{};
    final currentResult = <Vector2>{};
    for (final shapeA in collidableA.hitboxes) {
      for (final shapeB in collidableB.hitboxes) {
        currentResult.addAll(shapeA.intersections(shapeB));
        if (currentResult.isNotEmpty) {
          result.addAll(currentResult);
          // Do callbacks to the involved shapes
          if (_shapeHashes.add(_combinedHash(shapeA, shapeB))) {
            shapeA.onCollisionStart(currentResult, shapeB);
            shapeB.onCollisionStart(currentResult, shapeA);
          }
          shapeA.onCollision(currentResult, shapeB);
          shapeB.onCollision(currentResult, shapeA);
          currentResult.clear();
        } else {
          _handleHitboxCollisionEnd(shapeA, shapeB);
        }
      }
    }
    return result;
  }

  int _combinedHash(Object o1, Object o2) {
    return o1.hashCode ^ o2.hashCode;
  }

  @override
  void _handleCollisionStart(
    Set<Vector2> intersectionPoints,
    HasHitboxes collidableA,
    HasHitboxes collidableB,
  ) {
    collidableA.onCollisionStart(intersectionPoints, collidableB);
    collidableB.onCollisionStart(intersectionPoints, collidableA);
  }

  @override
  void _handleCollisionEnd(HasHitboxes collidableA, HasHitboxes collidableB) {
    collidableA.onCollisionEnd(collidableB);
    collidableB.onCollisionEnd(collidableA);
    for (final hitboxA in collidableA.hitboxes) {
      for (final hitboxB in collidableB.hitboxes) {
        _handleHitboxCollisionEnd(hitboxA, hitboxB);
      }
    }
  }

  @override
  bool _hasActiveCollision(HasHitboxes collidableA, HasHitboxes collidableB) {
    return collidableA.activeCollisions.contains(collidableB);
  }

  bool _handleHitboxCollisionEnd(HasHitboxes hitboxA, HasHitboxes hitboxB) {
    final activeCollision = hitboxA.contains(hitboxB);
    if (activeCollision) {
      hitboxA.onCollisionEnd(hitboxB);
      hitboxB.onCollisionEnd(hitboxA);
      _shapeHashes.remove(_combinedHash(hitboxA, hitboxB));
    }
    return activeCollision;
  }
}
