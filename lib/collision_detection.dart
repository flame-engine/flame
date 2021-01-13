import 'dart:math' as math;

import 'components.dart';
import 'components/mixins/collidable.dart';
import 'extensions.dart';

/// Check whether any [Collidable] in [collidables] collide with each other
/// or [screenSize] (if defined), and call callbacks accordingly
void collisionDetection(List<Collidable> collidables, {Vector2 screenSize}) {
  for (int x = 0; x < collidables.length - 1; x++) {
    print("Running with $collidables");
    final collidableX = collidables[x];
    for (int y = x + 1; y < collidables.length; y++) {
      final collidableY = collidables[y];
      final points = collisionPoints(collidableX.hitbox, collidableY.hitbox);
      if (points.isNotEmpty) {
        collidableX.collisionCallback(points, collidableY);
        collidableY.collisionCallback(points, collidableX);
      }
    }

    if (screenSize != null && collidableX.hasScreenCollision) {
      final intersectionPoints =
          hitboxSizeIntersections(collidableX.hitbox, screenSize);
      if (intersectionPoints.isNotEmpty) {
        collidableX.screenCollisionCallback(intersectionPoints);
      }
    }
  }
}

/// Returns the intersection points of the [hitboxX] and [hitboxY]
/// The two hitboxes are required to be convex
List<Vector2> collisionPoints(List<Vector2> hitboxX, List<Vector2> hitboxY) {
  assert(
    hitboxX.isNotEmpty && hitboxY.isNotEmpty,
    "Both hitboxes need to have elements",
  );
  final intersectionPoints = <Vector2>[];
  int x = 1;
  int y = 1;
  var pointX1 = hitboxX[x - 1];
  var pointX2 = hitboxX[x % hitboxX.length];
  var pointY1 = hitboxY[y - 1];
  var pointY2 = hitboxY[y % hitboxY.length];
  var lineX = LinearEquation.fromPoints(pointX1, pointX2);
  var lineY = LinearEquation.fromPoints(pointY1, pointY2);

  void advanceX() {
    x++;
    pointX1 = hitboxX[x - 1];
    pointX2 = hitboxX[x % hitboxX.length];
    lineX = LinearEquation.fromPoints(pointX1, pointX2);
  }

  void advanceY() {
    y++;
    pointY1 = hitboxY[y - 1];
    pointY2 = hitboxY[y % hitboxY.length];
    lineY = LinearEquation.fromPoints(pointY1, pointY2);
  }

  bool isOutside(Vector2 a, Vector2 b) {
    return a.x.abs() + a.y.abs() > b.x.abs() + b.y.abs();
  }

  void advanceOutsideLine() {
    if(isOutside(pointX2, pointY2)) {
      advanceX();
    } else {
      advanceY();
    }
  }

  while (x < hitboxX.length && y < hitboxY.length) {
    // TODO: Remember to check if lines are on each other
    if(lineX.isPointedAt(pointY1, pointY2)) {
      if(lineY.isPointedAt(pointX1, pointX2)) {
        // Both lines point at each other, advance outside line
        advanceOutsideLine();
      } else {
        // The ray formed by the Y points are pointing at [lineX]
        advanceY();
      }
    } else if(lineY.isPointedAt(pointX1, pointX2)) {
      // The ray formed by the X points are pointing at [lineX]
      advanceX();
    } else {
      // The lines are not pointing towards each other, advance the outside one
      // and check for an intersection
      final intersection = lineSegmentIntersection(pointX1, pointX2, pointY1, pointY2);
      if(intersection.isNotEmpty) {
        intersectionPoints.addAll(intersection);
      }
      advanceOutsideLine();
    }
  }
  return intersectionPoints;
}

/// Checks whether the [hitbox] represented by the list of [Vector2] contains
/// the [point].
bool containsPoint(Vector2 point, List<Vector2> hitbox) {
  for (int i = 0; i < hitbox.length; i++) {
    final previousNode = hitbox[i];
    final node = hitbox[(i + 1) % hitbox.length];
    final isOutside = (node.x - previousNode.x) * (point.y - previousNode.y) -
            (point.x - previousNode.x) * (node.y - previousNode.y) >
        0;
    if (isOutside) {
      // Point is outside of convex polygon
      return false;
    }
  }
  return true;
}

// Rotates the [point] with [angle] around [position]
Vector2 rotatePoint(Vector2 point, double angle, Vector2 position) {
  return Vector2(
    math.cos(angle) * (point.x - position.x) -
        math.sin(angle) * (point.y - position.y) +
        position.x,
    math.sin(angle) * (point.x - position.x) +
        math.cos(angle) * (point.y - position.y) +
        position.y,
  );
}

class LinearEquation {
  final double a;
  final double b;
  final double c;

  const LinearEquation(this.a, this.b, this.c);

  static LinearEquation fromPoints(Vector2 p1, Vector2 p2) {
    // ax + by = c
    final a = p2.y - p1.y;
    final b = p1.x - p2.x;
    final c = a * p1.x + b * p1.y;
    return LinearEquation(a, b, c);
  }
  
  bool isPointedAt(Vector2 from, Vector2 through) {
    final line = LinearEquation.fromPoints(from, through);
    final result = lineIntersection(this, line);
    if(result.isNotEmpty) {
      final delta = through - from;
      final intersection = result.first;
      final intersectionDelta = intersection - through;
      // Whether the two points [from] and [through] forms a ray that points on
      // the line represented by this object
      if(delta.x.sign == intersectionDelta.x.sign &&
         delta.y.sign == intersectionDelta.y.sign) {
        return true;
      }
    }
    return false;
  }
}

/// Returns an empty list if there is no intersection
List<Vector2> lineIntersection(LinearEquation line1, LinearEquation line2) {
  final determinant = line1.a * line2.b - line2.a * line1.b;
  if (determinant == 0) {
    //The lines are parallel and have no intersection
    return [];
  }
  return [Vector2(
    (line2.b * line1.c - line1.b * line2.c) / determinant,
    (line1.a * line2.c - line2.a * line1.c) / determinant,
  )];
}

/// Returns an empty list if there is no intersection
List<Vector2> lineSegmentIntersection(
  Vector2 a1,
  Vector2 a2,
  Vector2 b1,
  Vector2 b2,
) {
  final line1 = LinearEquation.fromPoints(a1, a2);
  final line2 = LinearEquation.fromPoints(a1, a2);
  final result = lineIntersection(line1, line2);
  if(result.isNotEmpty) {
    final intersection = result.first;
    if (math.min(a1.x, b1.x) <= intersection.x &&
        intersection.x <= math.max(a2.x, b2.x) &&
        math.min(a1.y, b1.y) <= intersection.y &&
        intersection.y <= math.max(a2.y, b2.y)) {
      // The intersection is within the two segments
      return result;
    }
  }
  return [];
}

/// Returns where the hitbox edges of the [hitbox] intersects the box
/// defined by [size] (usually the screen size).
List<Vector2> hitboxSizeIntersections(List<Vector2> hitbox, Vector2 size) {
  final screenBounds = [
    Vector2(0, 0),
    Vector2(size.x, 0),
    size,
    Vector2(0, size.y),
  ];
  final intersectionPoints = <Vector2>[];
  for (int x = 1; x < hitbox.length; x++) {
    for (int y = 1; y < screenBounds.length; y++) {
      intersectionPoints.addAll(
        lineSegmentIntersection(
          hitbox[x - 1],
          hitbox[x % hitbox.length],
          screenBounds[y - 1],
          screenBounds[y % screenBounds.length],
        ),
      );
    }
  }
  return intersectionPoints;
}
