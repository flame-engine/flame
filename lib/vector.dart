library flame.vector_math;

export 'package:vector_math/vector_math_64.dart' show Vector2;

import 'dart:math';
import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

class VectorUtil {
  /// Creates converting integers to double.
  ///
  /// Internal representation is still using double, the conversion is made in the constructor only.
  static Vector2 fromInts(int x, int y) => Vector2(x.toDouble(), y.toDouble());

  /// Creates a [Vector2] using an [Offset]
  static Vector2 fromOffset(Offset offset) => Vector2(offset.dx, offset.dy);

  /// Creates a [Vector2] using an [Size]
  static Vector2 fromSize(Size size) => Vector2(size.width, size.height);

  /// Creates a [Vector2] using a [math.Point]
  static Vector2 fromPoint(Point point) => Vector2(point.x, point.y);

  /// Creates an [Offset] from a [Vector2]
  static Offset toOffset(Vector2 v) => Offset(v.x, v.y);

  /// Creates an [Size] from a [Vector2]
  static Size toSize(Vector2 v) => Size(v.x, v.y);

  /// Creates a [math.Point] from a [Vector2]
  static Point toPoint(Vector2 v) => Point(v.x, v.y);

  /// Creates a [Rect] from two [Vector2]
  static Rect rectFrom(Vector2 topLeft, Vector2 size) {
    return Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
  }

  /// Creates bounds in from of a [Rect] from a list of [Vector2]
  static Rect bounds(List<Vector2> pts) {
    final double minx = pts.map((e) => e.x).reduce(min);
    final double maxx = pts.map((e) => e.x).reduce(max);
    final double miny = pts.map((e) => e.y).reduce(min);
    final double maxy = pts.map((e) => e.y).reduce(max);
    return Rect.fromPoints(Offset(minx, miny), Offset(maxx, maxy));
  }

  /// Linearly interpolate between two vectors.
  static Vector2 lerp(Vector2 a, Vector2 b, double t) {
    return a + (b - a) * t;
  }

  /// Rotates the gives [Vector2] with [angle] in radians
  static void rotate(Vector2 v, double angle) {
    v.setValues(
        v.x * cos(angle) - v.y * sin(angle),
        v.x * sin(angle) + v.y * cos(angle),
    );
  }

  /// Returns a new [Vector2] that is [v] rotated with [angle] in radians
  static Vector2 rotated(Vector2 v, double angle) {
    return Vector2(
        v.x * cos(angle) - v.y * sin(angle),
        v.x * sin(angle) + v.y * cos(angle),
    );
  }

  /// Returns a new vector with the [length] scaled to [newLength], without changing direction.
  ///
  /// If you try to scale the zero (empty) vector, it will remain unchanged, and no error will be thrown.
  static Vector2 scaledTo(Vector2 v, double newLength) {
    final l = v.length;
    if (l == 0) {
      return v;
    }
    return v * (newLength.abs() / l);
  }

  /// Changes the [length] of the vector to the length provided, without changing direction.
  ///
  /// If you try to scale the zero (empty) vector, it will remain unchanged, and no error will be thrown.
  static void scaleTo(Vector2 v, double newLength) {
    final l = v.length;
    if (l != 0) {
      v.setFrom(v * (newLength.abs() / l));
    }
  }
}
