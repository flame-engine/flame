import 'dart:math' as math;

import 'components.dart';
import 'extensions.dart';

/// Checks whether the [polygon] represented by the list of [Vector2] contains
/// the [point].
bool containsPoint(Vector2 point, List<Vector2> polygon) {
  for (int i = 0; i < polygon.length; i++) {
    final previousNode = polygon[i];
    final node = polygon[(i + 1) % polygon.length];
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
