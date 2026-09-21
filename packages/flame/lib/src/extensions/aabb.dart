import 'dart:math' as math;

import 'package:flame/extensions.dart';

extension Aabb2Extension on Aabb2 {
  /// Creates a [Rect] starting in [min] and going the [max]
  Rect toRect() => Rect.fromLTRB(min.x, min.y, max.x, max.y);

  /// Creates a [Rect] of the area that this and [other] both cover.
  ///
  /// The [Rect] has a negative width or height if the boxes don't overlap.
  Rect intersectionWithAabb2(Aabb2 other) {
    final otherMin = other.min;
    final otherMax = other.max;
    return Rect.fromLTRB(
      math.max(min.x, otherMin.x),
      math.max(min.y, otherMin.y),
      math.min(max.x, otherMax.x),
      math.min(max.y, otherMax.y),
    );
  }

  /// Creates an [Aabb2] from a [vertices] list.
  static Aabb2 fromVertices(List<Vector2> vertices) {
    if (vertices.isEmpty) {
      return Aabb2();
    }
    final first = vertices.first;
    final box = Aabb2.minMax(first, first);
    if (vertices.length > 1) {
      vertices.forEach(box.hullPoint);
    }
    return box;
  }
}
