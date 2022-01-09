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
          handleCollisionStart(intersectionPoints, itemA, itemB);
        }
        handleCollision(intersectionPoints, itemA, itemB);
      } else if (_hasActiveCollision(itemA, itemB)) {
        handleCollisionEnd(itemA, itemB);
      }
    });
  }

  /// Check what the intersection points of two items are,
  /// returns an empty list if there are no intersections.
  Set<Vector2> intersections(T itemA, T itemB);
  bool _hasActiveCollision(T itemA, T itemB);
  void handleCollisionStart(Set<Vector2> intersectionPoints, T itemA, T itemB);
  void handleCollision(Set<Vector2> intersectionPoints, T itemA, T itemB);
  void handleCollisionEnd(T itemA, T itemB);
}

/// Check whether any [HasHitboxes] in [items] collide with each other and
/// call their callback methods accordingly.
class StandardCollisionDetection extends CollisionDetection<HasHitboxes> {
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
      handleCollisionEnd(collidable, otherCollidable);
    });
    super.remove(collidable);
  }

  // This is created outside of `intersections` so that it doesn't have to be
  // created for every intersections call.
  final _currentResult = <Vector2>{};

  /// Check what the intersection points of two collidables are,
  /// returns an empty list if there are no intersections.
  @override
  Set<Vector2> intersections(
    HasHitboxes collidableA,
    HasHitboxes collidableB,
  ) {
    final result = <Vector2>{};
    _currentResult.clear();
    for (final shapeA in collidableA.hitboxes) {
      for (final shapeB in collidableB.hitboxes) {
        _currentResult.addAll(shapeA.intersections(shapeB));
        if (_currentResult.isNotEmpty) {
          result.addAll(_currentResult);
          // Do callbacks to the involved shapes
          if (!_hasActiveCollision(shapeA, shapeB)) {
            handleCollisionStart(_currentResult, shapeA, shapeB);
          }
          handleCollision(_currentResult, shapeA, shapeB);
          _currentResult.clear();
        } else {
          handleCollisionEnd(shapeA, shapeB);
        }
      }
    }
    return result;
  }

  @override
  void handleCollisionStart(
    Set<Vector2> intersectionPoints,
    HasHitboxes collidableA,
    HasHitboxes collidableB,
  ) {
    collidableA.onCollisionStart(intersectionPoints, collidableB);
    collidableB.onCollisionStart(intersectionPoints, collidableA);
  }

  @override
  void handleCollision(
    Set<Vector2> intersectionPoints,
    HasHitboxes collidableA,
    HasHitboxes collidableB,
  ) {
    collidableA.onCollision(intersectionPoints, collidableB);
    collidableB.onCollision(intersectionPoints, collidableA);
  }

  @override
  void handleCollisionEnd(HasHitboxes collidableA, HasHitboxes collidableB) {
    collidableA.onCollisionEnd(collidableB);
    collidableB.onCollisionEnd(collidableA);
  }

  @override
  bool _hasActiveCollision(HasHitboxes collidableA, HasHitboxes collidableB) {
    return collidableA.activeCollision(collidableB);
  }
}
