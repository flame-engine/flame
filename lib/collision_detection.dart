import 'dart:math' as math;

import 'components.dart';
import 'components/mixins/collidable.dart';
import 'extensions.dart';

/// Check whether any [Collidable] in [collidables] collide with each other
/// or [screenSize] (if defined), and call callbacks accordingly
void collisionDetection(List<Collidable> collidables, {Vector2 screenSize}) {
  print("=================================");
  for (int x = 0; x < collidables.length - 1; x++) {
    final collidableX = collidables[x];
    for (int y = x + 1; y < collidables.length; y++) {
      final collidableY = collidables[y];
      final points = collisionPoints(collidableX.hitbox, collidableY.hitbox);
      if (points.isNotEmpty) {
        print("booom");
        collidableX.collisionCallback(points, collidableY);
        collidableY.collisionCallback(points, collidableX);
      }
    }

    if (screenSize != null && collidableX.hasScreenCollision) {
      final intersectionPoints =
          hitboxSizeIntersections(collidableX.hitbox, screenSize);
      if (intersectionPoints.isNotEmpty) {
        print("kabooom $intersectionPoints");
        collidableX.screenCollisionCallback(intersectionPoints);
      }
    }
  }
}

/// Returns the intersection points of the [hitboxA] and [hitboxB]
/// The two hitboxes are required to be convex
List<Vector2> collisionPoints(List<Vector2> hitboxA, List<Vector2> hitboxB) {
  assert(
    hitboxA.isNotEmpty && hitboxB.isNotEmpty,
    "Both hitboxes need to have elements",
  );
  final intersectionPoints = <Vector2>[];
  Vector2 hitboxCenter(List<Vector2> hitbox) {
    return hitbox.fold(Vector2.zero(), (Vector2 sum, v) => sum + v) /
        hitbox.length.toDouble();
  }

  final center = hitboxCenter([hitboxCenter(hitboxA), hitboxCenter(hitboxB)]);
  int a = 1;
  int b = 1;
  var pointA1 = hitboxA[a - 1];
  var pointA2 = hitboxA[a % hitboxA.length];
  var pointB1 = hitboxB[b - 1];
  var pointB2 = hitboxB[b % hitboxB.length];
  var lineA = LinearFunction.fromPoints(pointA1, pointA2);
  var lineB = LinearFunction.fromPoints(pointB1, pointB2);

  void advanceA() {
    a++;
    pointA1 = hitboxA[a - 1];
    pointA2 = hitboxA[a % hitboxA.length];
    lineA = LinearFunction.fromPoints(pointA1, pointA2);
  }

  void advanceB() {
    b++;
    pointB1 = hitboxB[b - 1];
    pointB2 = hitboxB[b % hitboxB.length];
    lineB = LinearFunction.fromPoints(pointB1, pointB2);
  }

  // The point that is furthest away from the shared center of the components
  bool isOutside(Vector2 a, Vector2 b) {
    // TODO: This is not how to measure whether it is on the outside?
    return a.distanceToSquared(center) > b.distanceToSquared(center);
  }

  void advanceOutsideLine() {
    // This is wrong
    if (isOutside(pointA2, pointB2)) {
      print("advance outside A");
      advanceA();
    } else {
      print("advance outside B");
      advanceB();
    }
  }

  while (a < hitboxA.length || b < hitboxB.length) {
    print("A: $pointA1 $pointA2");
    print("B: $pointB1 $pointB2");
    if (lineA.isPointedAt(pointB1, pointB2)) {
      if (lineB.isPointedAt(pointA1, pointA2)) {
        // Both lines point at each other, advance outside line
        print("advance outside line");
        advanceOutsideLine();
      } else {
        // The ray formed by the B points are pointing at [lineA]
        print("advance B");
        advanceB();
      }
    } else if (lineB.isPointedAt(pointA1, pointA2)) {
      // The ray formed by the X points are pointing at [lineA]
      print("advance A");
      advanceA();
    } else {
      // The lines are not pointing towards each other, advance the outside one
      // and check for an intersection
      final intersection =
          lineSegmentIntersection(pointA1, pointA2, pointB1, pointB2);
      if (intersection.isNotEmpty) {
        print("intersection!");
        intersectionPoints.addAll(intersection);
      }
      print("Advance outside line because they are not pointing at each other");
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

// Rotates the [point] with [radians] around [position]
Vector2 rotatePoint(Vector2 point, double radians, Vector2 position) {
  return Vector2(
    math.cos(radians) * (point.x - position.x) -
        math.sin(radians) * (point.y - position.y) +
        position.x,
    math.sin(radians) * (point.x - position.x) +
        math.cos(radians) * (point.y - position.y) +
        position.y,
  );
}

/// This represents a linear function on the ax + by = c form
class LinearFunction {
  final double a;
  final double b;
  final double c;

  const LinearFunction(this.a, this.b, this.c);

  static LinearFunction fromPoints(Vector2 p1, Vector2 p2) {
    final a = p2.y - p1.y;
    final b = p1.x - p2.x;
    final c = p2.y * p1.x - p1.y * p2.x;
    return LinearFunction(a, b, c);
  }

  // TODO: Come up with a better name
  bool isPointedAt(Vector2 from, Vector2 through) {
    final line = LinearFunction.fromPoints(from, through);
    final result = lineIntersection(this, line);
    if (result.isNotEmpty) {
      final delta = through - from;
      final intersection = result.first;
      final intersectionDelta = intersection - through;
      // Whether the two points [from] and [through] forms a ray that points on
      // the line represented by this object
      if (delta.x.sign == intersectionDelta.x.sign &&
          delta.y.sign == intersectionDelta.y.sign) {
        return true;
      }
    }
    return false;
  }
  
  @override
  String toString() {
    final a0 = "${a}x";
    final b0 = b.isNegative ? "${b}y" : "+${b}y";
    return "$a0$b0=$c";
  } 
}

/// Returns an empty list if there is no intersection
List<Vector2> lineIntersection(LinearFunction line1, LinearFunction line2) {
  final determinant = line1.a * line2.b - line2.a * line1.b;
  if (determinant == 0) {
    //The lines are parallel and have no intersection
    return [];
  }
  return [
    Vector2(
      (line2.b * line1.c - line1.b * line2.c) / determinant,
      (line1.a * line2.c - line2.a * line1.c) / determinant,
    )
  ];
}

/// Returns an empty list if there is no intersection
/// If they go on top of each other the middle of the intersecting part is
/// the result
List<Vector2> lineSegmentIntersection(
  Vector2 a1,
  Vector2 a2,
  Vector2 b1,
  Vector2 b2,
) {
  final line1 = LinearFunction.fromPoints(a1, a2);
  final line2 = LinearFunction.fromPoints(b1, b2);
  final result = lineIntersection(line1, line2);
  if (result.isNotEmpty) {
    // The lines are not parallel
    final intersection = result.first;
    if (isPointOnSegment(intersection, a1, a2) &&
        isPointOnSegment(intersection, b1, b2)) {
      // The intersection point is on both line segments
      return result;
    }
  } else {
    // In here we know that the lines are parallel
    final overlaps = ({
      a1: isPointOnSegment(a1, b1, b2),
      a2: isPointOnSegment(a2, b1, b2),
      b1: isPointOnSegment(b1, a1, a2),
      b2: isPointOnSegment(b2, a1, a2)
    }..removeWhere((_key, onSegment) => !onSegment))
        .keys
        .toSet();
    if (overlaps.isNotEmpty) {
      return [overlaps.fold<Vector2>(Vector2.zero(), (sum, point) => sum + point) / overlaps.length.toDouble()];
    }
  }
  return [];
}

bool isPointOnSegment(Vector2 point, Vector2 a, Vector2 b) {
  const epsilon = 0.00001;
  final delta = b - a;
  final crossProduct = (point.y - a.y) * delta.x - (point.x - a.x) * delta.y;

  // compare versus epsilon for floating point values
  if (crossProduct.abs() > epsilon) {
    return false;
  }

  final dotProduct = (point.x - a.x) * delta.x + (point.y - a.y) * delta.y;
  if (dotProduct < 0) {
    return false;
  }

  final squaredLength = a.distanceToSquared(b);
  if (dotProduct > squaredLength) {
    return false;
  }

  return true;
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
