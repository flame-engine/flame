import 'dart:math';
import 'dart:ui';

import 'vector2.dart';

export 'dart:ui' show Rect;

extension RectExtension on Rect {
  /// Creates an [Offset] from the [Vector2]
  Offset toOffset() => Offset(width, height);

  /// Creates a [Vector2] starting in top left and going to [width, height].
  Vector2 toVector2() => Vector2(width, height);

  bool containsPoint(Vector2 vector) {
    return contains(vector.toOffset());
  }
}

// Until [extension] will allow static methods we need to keep these functions
// in a utility class
class RectFactory {
  /// Creates bounds in from of a [Rect] from a list of [Vector2]
  static Rect fromBounds(List<Vector2> pts) {
    final double minX = pts.map((e) => e.x).reduce(min);
    final double maxX = pts.map((e) => e.x).reduce(max);
    final double minY = pts.map((e) => e.y).reduce(min);
    final double maxY = pts.map((e) => e.y).reduce(max);
    return Rect.fromPoints(Offset(minX, minY), Offset(maxX, maxY));
  }
}
