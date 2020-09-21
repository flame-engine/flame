export 'package:vector_math/vector_math_64.dart' show Vector2;

import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

extension Vector2Extension on Vector2 {
  /// Creates an [Offset] from the [Vector2]
  Offset toOffset() => Offset(x, y);

  /// Creates a [Size] from the [Vector2]
  Size toSize() => Size(x, y);

  /// Creates a [Point] from the [Vector2]
  Point toPoint() => Point(x, y);

  /// Creates a [Rect] starting from [x, y] and going the [Vector2]
  Rect toRect(Vector2 to) => Rect.fromLTWH(x, y, to.x, to.y);

  /// Creates a [Rect] starting in origo and going the [Vector2]
  Rect toOriginRect() => Rect.fromLTWH(0, 0, x, y);

  /// Linearly interpolate towards another Vector2
  void lerp(Vector2 to, double t) {
    setFrom(this + (to - this) * t);
  }

  /// Rotates the [Vector2] with [angle] in radians
  void rotate(double angle) {
    setValues(
      x * cos(angle) - y * sin(angle),
      x * sin(angle) + y * cos(angle),
    );
  }

  /// Changes the [length] of the vector to the length provided, without changing direction.
  ///
  /// If you try to scale the zero (empty) vector, it will remain unchanged, and no error will be thrown.
  void scaleTo(double newLength) {
    final l = length;
    if (l != 0) {
      scale(newLength.abs() / l);
    }
  }
}

// Until [extension] will allow static methods we need to keep these functions
// in a utility class
class Vector2Factory {
  /// Creates a [Vector2] using an [Offset]
  static Vector2 fromOffset(Offset offset) => Vector2(offset.dx, offset.dy);

  /// Creates a [Vector2] using an [Size]
  static Vector2 fromSize(Size size) => Vector2(size.width, size.height);

  /// Creates a [Vector2] using a [Point]
  static Vector2 fromPoint(Point point) => Vector2(point.x, point.y);

  /// Creates bounds in from of a [Rect] from a list of [Vector2]
  static Rect fromBounds(List<Vector2> pts) {
    final double minx = pts.map((e) => e.x).reduce(min);
    final double maxx = pts.map((e) => e.x).reduce(max);
    final double miny = pts.map((e) => e.y).reduce(min);
    final double maxy = pts.map((e) => e.y).reduce(max);
    return Rect.fromPoints(Offset(minx, miny), Offset(maxx, maxy));
  }
}
