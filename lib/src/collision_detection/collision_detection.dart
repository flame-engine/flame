import 'dart:collection';

import '../components/mixins/collidable.dart';
import '../geometry/line_segment.dart';
import '../geometry/shape.dart';
import '../geometry/shape_intersections.dart' as shape_intersections;
import '../../extensions.dart';

/// Check whether any [Collidable] in [collidables] collide with each other
/// or [screenSize] (if defined), and call callbacks accordingly
void collisionDetection(List<Collidable> collidables, {Vector2 screenSize}) {
  for (int x = 0; x < collidables.length - 1; x++) {
    final collidableX = collidables[x];
    for (int y = x + 1; y < collidables.length; y++) {
      final collidableY = collidables[y];
      final points = intersections(collidableX, collidableY);
      if (points.isNotEmpty) {
        collidableX.collisionCallback(points, collidableY);
        collidableY.collisionCallback(points, collidableX);
      }
    }

    // TODO: Add screen as a rectangle and compare intersection
    //if (screenSize != null && collidableX.hasScreenCollision) {
    //  final intersectionPoints = intersections(collidableX.shapes, [screenSize])
    //      hitboxSizeIntersections(collidableX.shapes, screenSize);
    //  if (intersectionPoints.isNotEmpty) {
    //    print("kabooom $intersectionPoints");
    //    collidableX.screenCollisionCallback(intersectionPoints);
    //  }
    //}
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
        hitboxShapeA.collisionCallback(currentResult, hitboxShapeB);
        hitboxShapeB.collisionCallback(currentResult, hitboxShapeA);
        currentResult.clear();
      }
    }
  }
  return result;
}

/// Returns where the hitbox edges of the [hitbox] intersects the box
/// defined by [size] (usually the screen size).
Set<Vector2> hitboxSizeIntersections(
  UnmodifiableListView<Vector2> hitbox,
  Vector2 size,
) {
  final screenBounds = [
    Vector2(0, 0),
    Vector2(size.x, 0),
    size,
    Vector2(0, size.y),
  ];
  final intersectionPoints = <Vector2>{};
  for (int i = 0; i < hitbox.length; ++i) {
    final hitboxSegment = LineSegment(
      hitbox[i],
      hitbox[(i + 1) % hitbox.length],
    );
    for (int j = 0; j < screenBounds.length; ++j) {
      final screenSegment = LineSegment(
        screenBounds[j],
        screenBounds[(j + 1) % screenBounds.length],
      );
      intersectionPoints.addAll(hitboxSegment.intersections(screenSegment));
    }
  }
  return intersectionPoints;
}
