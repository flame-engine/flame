import 'dart:math' as math;

import 'components.dart';


/// Checks whether the [polygon] represented by the list of [Vector2] contains
/// the point. Note that the polygon list is mutated.
bool containsPoint(Vector2 point, List<Vector2> polygon) {
  polygon.add(polygon.first);
  for (int i = 1; i < polygon.length; i++) {
    final previousPoint = polygon[i - 1];
    final point = polygon[i];
    final isOutside =
        (point.x - previousPoint.x) * (point.y - previousPoint.y) -
                (point.x - previousPoint.x) * (point.y - previousPoint.y) >
            0;
    if (isOutside) {
      // Point is outside of convex polygon (only used for rectangles so far)
      return false;
    }
  }
  return true;
}

List<Vector2> collisionPoints(List<Vector2> polygon1, List<Vector2> polygon2) {
  return [];
}

