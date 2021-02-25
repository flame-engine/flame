import '../../extensions.dart';
import '../components/mixins/collidable.dart';

/// Check whether any [Collidable] in [collidables] collide with each other and
/// call their onCollision methods accordingly.
void collisionDetection(List<Collidable> collidables) {
  for (var x = 0; x < collidables.length; x++) {
    final collidableX = collidables[x];
    for (var y = x + 1; y < collidables.length; y++) {
      final collidableY = collidables[y];
      final points = intersections(collidableX, collidableY);
      if (points.isNotEmpty) {
        collidableX.onCollision(points, collidableY);
        collidableY.onCollision(points, collidableX);
      }
    }
  }
}

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
