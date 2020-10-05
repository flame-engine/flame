export 'dart:ui' show Rect;

import 'dart:math';
import 'dart:ui';

import './vector2.dart';

extension RectExtension on Rect {
  /// Creates an [Offset] from the [Vector2]
  Offset toOffset() => Offset(width, height);

  /// Creates a [Vector2] starting in top left and going to [width, height].
  Vector2 toVector2() => Vector2(width, height);
}

// Until [extension] will allow static methods we need to keep these functions
// in a utility class
class RectFactory {
  /// Creates bounds in from of a [Rect] from a list of [Vector2]
  static Rect fromBounds(List<Vector2> pts) {
    final double minx = pts.map((e) => e.x).reduce(min);
    final double maxx = pts.map((e) => e.x).reduce(max);
    final double miny = pts.map((e) => e.y).reduce(min);
    final double maxy = pts.map((e) => e.y).reduce(max);
    return Rect.fromPoints(Offset(minx, miny), Offset(maxx, maxy));
  }
}
