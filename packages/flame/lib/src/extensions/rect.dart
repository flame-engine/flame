import 'dart:math';
import 'dart:ui';

import '../../geometry.dart';
import 'offset.dart';
import 'vector2.dart';

export 'dart:ui' show Rect;

extension RectExtension on Rect {
  /// Creates an [Offset] from the [Rect]
  Offset toOffset() => Offset(width, height);

  /// Creates a [Vector2] starting in top left and going to [width, height].
  Vector2 toVector2() => Vector2(width, height);

  /// Whether this [Rect] contains a [Vector2] point or not
  bool containsPoint(Vector2 point) => contains(point.toOffset());

  /// Whether the segment formed by [pointA] and [pointB] intersects this [Rect]
  bool intersectsSegment(Vector2 pointA, Vector2 pointB) {
    return min(pointA.x, pointB.x) <= right &&
        min(pointA.y, pointB.y) <= bottom &&
        max(pointA.x, pointB.x) >= left &&
        max(pointA.y, pointB.y) >= top;
  }

  bool intersectsLineSegment(LineSegment segment) {
    return intersectsSegment(segment.from, segment.to);
  }

  List<Vector2> toVertices() {
    return [
      topLeft.toVector2(),
      topRight.toVector2(),
      bottomRight.toVector2(),
      bottomLeft.toVector2(),
    ];
  }
}

// Until [extension] will allow static methods we need to keep these functions
// in a utility class
class RectFactory {
  /// Creates bounds in from of a [Rect] from a list of [Vector2]
  static Rect fromBounds(List<Vector2> pts) {
    final minX = pts.map((e) => e.x).reduce(min);
    final maxX = pts.map((e) => e.x).reduce(max);
    final minY = pts.map((e) => e.y).reduce(min);
    final maxY = pts.map((e) => e.y).reduce(max);
    return Rect.fromPoints(Offset(minX, minY), Offset(maxX, maxY));
  }
}
