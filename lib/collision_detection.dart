import 'dart:math' as math;

import 'components.dart';


/// Checks whether the [polygon] represented by the list of [Vector2] contains
/// the [point].
bool containsPoint(Vector2 point, List<Vector2> polygon) {
  for (int i = 0; i < polygon.length; i++) {
    final previousNode = polygon[i];
    final node = polygon[(i + 1) % polygon.length];
    final isOutside =
        (node.x - previousNode.x) * (point.y - previousNode.y) -
                (point.x - previousNode.x) * (node.y - previousNode.y) >
            0;
    if (isOutside) {
      // Point is outside of convex polygon
      return false;
    }
  }
  return true;
}

class LinearEquation {
  final double a;
  final double b;
  final double c;

  const LinearEquation(this.a, this.b, this.c);

  static LinearEquation fromPoints(Vector2 a1, Vector2 a2) {
    // ax + by = c
    final a = a2.y - a1.y;
    final b = a1.x - a2.x;
    final c = a * a1.x + b * a1.y;
    return LinearEquation(a, b, c);
  }
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
  final determinant = line1.a * line2.b - line2.a * line1.b;
  if (determinant == 0) {
    //The lines are parallel and have no intersection
    return [];
  }
  final result = Vector2(
    (line2.b * line1.c - line1.b * line2.c) / determinant,
    (line1.a * line2.c - line2.a * line1.c) / determinant,
  );
  if (math.min(a1.x, b1.x) <= result.x &&
      result.x <= math.max(a2.x, b2.x) &&
      math.min(a1.y, b1.y) <= result.y &&
      result.y <= math.max(a2.y, b2.y)) {
    // The result is within the two segments
    return [result];
  }
  return [];
}

/// Determines where (or if) two polygons intersect, if they don't have any
/// intersection an empty list will be returned.
List<Vector2> collisionPoints(List<Vector2> polygon1, List<Vector2> polygon2) {
  int x = 0;
  int y = 0;

  while (x < polygon1.length || y < polygon2.length) {}

  return [];
}
