import '../../extensions.dart';
import '../components/mixins/collidable.dart';

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
