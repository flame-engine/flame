import '../../extensions.dart';
import '../../geometry.dart';
import '../components/mixins/collidable.dart';
import 'broadphase.dart';
import 'hitbox_shape.dart';
import 'sweep.dart';
import 'tuple.dart';

abstract class CollisionDetection<T extends CollisionItem<T>> {
  final List<T> items = [];
  late final Broadphase<T> broadphase;
  final Set<int> _collisionHashes = {};

  CollisionDetection({BroadphaseType type = BroadphaseType.sweep}) {
    switch (type) {
      case BroadphaseType.sweep:
        broadphase = Sweep<T>(items);
    }
  }

  void add(T item);
  void addAll(Iterable<T> items) => items.forEach(add);

  /// Removes the [item] from the collision detection, if you just want
  /// to temporarily inactivate it you can set
  /// `collidableType = CollidableType.inactive;` instead.
  void remove(T item);

  /// Removes the [collidable] from the collision detection, if you just want
  /// to temporarily inactivate it you can set
  /// `collidableType = CollidableType.inactive;` instead.
  /// This calls [Collidable.onCollisionEnd] and [HitboxShape.onCollisionEnd]
  /// for [Collidable]s that are removed from the game.
  void remove(Collidable collidable) {
    items.remove(collidable);
    // TODO(spydon): make more efficient
    items.forEach((otherCollidable) {
      final activeCollision = _handleCollisionEnd(collidable, otherCollidable);
      if (activeCollision) {
        for (final hitboxA in collidable.hitboxes) {
          for (final hitboxB in otherCollidable.hitboxes) {
            _handleHitboxCollisionEnd(hitboxA, hitboxB);
          }
        }
      }
    });
  }

  void removeAll(Iterable<T> items) => items.forEach(remove);

  int _combinedHash(Object o1, Object o2) {
    return o1.hashCode ^ o2.hashCode;
  }

  /// Run the collision detection on the current state of the [items].
  void run() {
    broadphase.query().forEach((tuple) {
      final itemA = tuple.a;
      final itemB = tuple.b;

      final intersectionPoints = intersections(itemA, itemB);
      if (intersectionPoints.isNotEmpty) {
        final collisionHash = _combinedHash(itemA, itemB);
        if (_collisionHashes.add(collisionHash)) {
          itemA.onCollisionStart(intersectionPoints, itemB);
          itemB.onCollisionStart(intersectionPoints, itemA);
        }
        itemA.onCollision(intersectionPoints, itemB);
        itemB.onCollision(intersectionPoints, itemA);
      } else {
        _handleCollisionEnd(itemA, itemB);
      }
    });
  }

  bool hasActiveCollision(T itemA, T itemB) {
    return _collisionHashes.contains(_combinedHash(itemA, itemB));
  }

  bool _handleCollisionEnd(T itemA, T itemB) {
    final activeCollision = hasActiveCollision(itemA, itemB);
    if (activeCollision) {
      itemA.onCollisionEnd(itemB);
      itemB.onCollisionEnd(itemA);
      _collisionHashes.remove(_combinedHash(itemA, itemB));
    }
    return activeCollision;
  }

  /// Check what the intersection points of two items are,
  /// returns an empty list if there are no intersections.
  Set<Vector2> intersections(T itemA, T itemB);
}

/// Check whether any [Collidable] in [items] collide with each other and
/// call their onCollision methods accordingly.
class CollidableCollisionDetection extends CollisionDetection<Collidable> {
  final Set<int> _shapeHashes = {};

  CollidableCollisionDetection({BroadphaseType type = BroadphaseType.sweep})
      : super(type: type);

  @override
  void add(Collidable collidable) {
    items.add(collidable);
  }

  /// Check what the intersection points of two collidables are,
  /// returns an empty list if there are no intersections.
  @override
  Set<Vector2> intersections(
    Collidable collidableA,
    Collidable collidableB,
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

  bool hasActiveShapeCollision(HitboxShape shapeA, HitboxShape shapeB) {
    return _shapeHashes.contains(
      _combinedHash(shapeA, shapeB),
    );
  }

  bool _handleHitboxCollisionEnd(HitboxShape hitboxA, HitboxShape hitboxB) {
    final activeCollision = hasActiveShapeCollision(hitboxA, hitboxB);
    if (activeCollision) {
      hitboxA.onCollisionEnd(hitboxB);
      hitboxB.onCollisionEnd(hitboxA);
      _shapeHashes.remove(_combinedHash(hitboxA, hitboxB));
    }
    return activeCollision;
  }
}
