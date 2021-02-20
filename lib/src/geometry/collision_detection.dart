import 'shape.dart';
import '../components/mixins/collidable.dart';
import '../../extensions.dart';
import '../../geometry.dart';

/// Check whether any [Collidable] in [collidables] collide with each other and
/// call their onCollision methods accordingly.
void collisionDetection(List<Collidable> collidables) {
  for (int x = 0; x < collidables.length; x++) {
    final collidableX = collidables[x];
    for (int y = x + 1; y < collidables.length; y++) {
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
  for (Shape shapeA in collidableA.shapes) {
    for (Shape shapeB in collidableB.shapes) {
      final currentResult = shapeA.intersections(shapeB);
      if (currentResult.isNotEmpty) {
        result.addAll(currentResult);
        // Do callbacks to the involved shapes
        final hitboxShapeA = shapeA as HitboxShape;
        final hitboxShapeB = shapeB as HitboxShape;
        hitboxShapeA.onCollision(currentResult, hitboxShapeB);
        hitboxShapeB.onCollision(currentResult, hitboxShapeA);
        currentResult.clear();
      }
    }
  }
  return result;
}
