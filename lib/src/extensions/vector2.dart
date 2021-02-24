import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

export 'package:vector_math/vector_math_64.dart' hide Colors;

extension Vector2Extension on Vector2 {
  /// Creates an [Offset] from the [Vector2]
  Offset toOffset() => Offset(x, y);

  /// Creates a [Size] from the [Vector2]
  Size toSize() => Size(x, y);

  /// Creates a [Point] from the [Vector2]
  Point toPoint() => Point(x, y);

  /// Creates a [Rect] starting from [x, y] and having the size of the
  /// argument [Vector2]
  Rect toPositionedRect(Vector2 size) => Rect.fromLTWH(x, y, size.x, size.y);

  /// Creates a [Rect] starting in origin and going the [Vector2]
  Rect toRect() => Rect.fromLTWH(0, 0, x, y);

  /// Linearly interpolate towards another Vector2
  void lerp(Vector2 to, double t) {
    setFrom(this + (to - this) * t);
  }

  /// Rotates the [Vector2] with [angle] in radians
  /// rotates around [center] if it is defined
  void rotate(double angle, {Vector2? center}) {
    if (center == null) {
      setValues(
        x * cos(angle) - y * sin(angle),
        x * sin(angle) + y * cos(angle),
      );
    } else {
      setValues(
        cos(angle) * (x - center.x) - sin(angle) * (y - center.y) + center.x,
        sin(angle) * (x - center.x) + cos(angle) * (y - center.y) + center.y,
      );
    }
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

  /// Modulo/Remainder
  Vector2 operator %(Vector2 mod) => Vector2(x % mod.x, y % mod.y);

  /// Create a Vector2 with ints as input
  static Vector2 fromInts(int x, int y) => Vector2(x.toDouble(), y.toDouble());
}
