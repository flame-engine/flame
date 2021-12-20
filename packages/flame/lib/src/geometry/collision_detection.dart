import '../../extensions.dart';
import '../../geometry.dart';
import '../components/mixins/collidable.dart';

final Set<int> _collidableHashes = {};
final Set<int> _shapeHashes = {};

int _collidableTypeCompare(Collidable a, Collidable b) {
  return a.collidableType.index - b.collidableType.index;
}

/// Check whether any [Collidable] in [collidables] collide with each other and
/// call their onCollision methods accordingly.
void collisionDetection(List<Collidable> collidables) {
  collidables.sort(_collidableTypeCompare);
  for (var x = 0; x < collidables.length; x++) {
    final collidableX = collidables[x];
    if (collidableX.collidableType != CollidableType.active) {
      break;
    }

    for (var y = x + 1; y < collidables.length; y++) {
      final collidableY = collidables[y];
      if (collidableY.collidableType == CollidableType.inactive) {
        break;
      }

      final intersectionPoints = intersections(collidableX, collidableY);
      if (intersectionPoints.isNotEmpty) {
        final collisionHash = _combinedHash(collidableX, collidableY);
        if (_collidableHashes.add(collisionHash)) {
          collidableX.onCollisionStart(intersectionPoints, collidableY);
          collidableY.onCollisionStart(intersectionPoints, collidableX);
        }
        collidableX.onCollision(intersectionPoints, collidableY);
        collidableY.onCollision(intersectionPoints, collidableX);
      } else {
        _handleCollisionEnd(collidableX, collidableY);
      }
    }
  }
}

bool hasActiveCollision(Collidable collidableA, Collidable collidableB) {
  return _collidableHashes.contains(
    _combinedHash(collidableA, collidableB),
  );
}

bool hasActiveShapeCollision(HitboxShape shapeA, HitboxShape shapeB) {
  return _shapeHashes.contains(
    _combinedHash(shapeA, shapeB),
  );
}

bool _handleCollisionEnd(Collidable collidableA, Collidable collidableB) {
  final activeCollision = hasActiveCollision(collidableA, collidableB);
  if (activeCollision) {
    collidableA.onCollisionEnd(collidableB);
    collidableB.onCollisionEnd(collidableA);
    _collidableHashes.remove(_combinedHash(collidableA, collidableB));
  }
  return activeCollision;
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

/// Used to call [Collidable.onCollisionEnd] and [HitboxShape.onCollisionEnd]
/// for [Collidable]s that are removed from the game.
void handleRemovedCollidable(
  final Collidable collidable,
  final List<Collidable> collidables,
) {
  collidables.forEach((otherCollidable) {
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

/// Check what the intersection points of two collidables are
/// returns an empty list if there are no intersections
Set<Vector2> intersections(
  Collidable collidableA,
  Collidable collidableB,
) {
  if (!collidableA.possiblyOverlapping(collidableB)) {
    // These collidables can't have any intersection points
    if (hasActiveCollision(collidableA, collidableB)) {
      for (final shapeA in collidableA.hitboxes) {
        for (final shapeB in collidableB.hitboxes) {
          _handleHitboxCollisionEnd(shapeA, shapeB);
        }
      }
    }
    return {};
  }

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
