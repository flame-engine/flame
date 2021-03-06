import '../../extensions.dart';
import '../components/mixins/collidable.dart';

/// Check whether any [Collidable] in [collidables] collide with each other and
/// call their onCollision methods accordingly.
void collisionDetection(List<Collidable> collidables) {
  for (var x = 0; x < collidables.length; x++) {
    final collidableX = collidables[x];
    if (collidableX.collisionType != CollidableType.active) {
      continue;
    }

    for (var y = 0; y < collidables.length; y++) {
      final collidableY = collidables[y];
      if ((y <= x && collidableY.collisionType == CollidableType.active) ||
          collidableY.collisionType == CollidableType.inactive) {
        // These collidables will already have been checked towards each other
        // or [collidableY] is inactive
        continue;
      }

      final intersectionPoints = intersections(collidableX, collidableY);
      if (intersectionPoints.isNotEmpty) {
        collidableX.onCollision(intersectionPoints, collidableY);
        collidableY.onCollision(intersectionPoints, collidableX);
      }
    }
  }
}

/// Check what the intersection points of two collidables are
/// returns an empty list if there are no intersections
Set<Vector2> intersections(
  Collidable collidableA,
  Collidable collidableB,
) {
  if (!collidableA.possiblyOverlapping(collidableB)) {
    // These collidables can't have any intersection points
    return {};
  }

  final result = <Vector2>{};
  final currentResult = <Vector2>{};
  for (final shapeA in collidableA.shapes) {
    for (final shapeB in collidableB.shapes) {
      currentResult.addAll(shapeA.intersections(shapeB));
      if (currentResult.isNotEmpty) {
        result.addAll(currentResult);
        // Do callbacks to the involved shapes
        shapeA.onCollision(currentResult, shapeB);
        shapeB.onCollision(currentResult, shapeA);
        currentResult.clear();
      }
    }
  }
  return result;
}
