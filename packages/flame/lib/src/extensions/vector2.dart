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

  /// A rectangle constructor operator.
  ///
  /// Combines two [Vector2]s to form a Rect whose top-left coordinate is the
  /// point given by adding this vector, the left-hand-side operand,
  /// to the origin, and whose size is the right-hand-side operand.
  Rect operator &(Vector2 size) => toPositionedRect(size);

  /// Creates a [Rect] starting from (x, y) and having the size of the
  /// argument [Vector2]
  Rect toPositionedRect(Vector2 size) => Rect.fromLTWH(x, y, size.x, size.y);

  /// Creates a [Rect] starting in origin and going the [Vector2]
  Rect toRect() => Rect.fromLTWH(0, 0, x, y);

  /// Linearly interpolate towards another Vector2
  void lerp(Vector2 to, double t) {
    setFrom(this + (to - this) * t);
  }

  /// Whether the [Vector2] is the zero vector or not
  bool isZero() => x == 0 && y == 0;

  /// Whether the [Vector2] is the identity vector or not
  bool isIdentity() => x == 1 && y == 1;

  /// Distance to [other] vector, using the taxicab (L1) geometry.
  double taxicabDistanceTo(Vector2 other) {
    return (x - other.x).abs() + (y - other.y).abs();
  }

  /// Rotates the [Vector2] with [angle] in radians
  /// rotates around [center] if it is defined
  /// In a screen coordinate system (where the y-axis is flipped) it rotates in
  /// a clockwise fashion
  /// In a normal coordinate system it rotates in a counter-clockwise fashion
  void rotate(double angle, {Vector2? center}) {
    if (isZero() || angle == 0) {
      // No point in rotating the zero vector or to rotate with 0 as angle
      return;
    }
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

  /// Changes the [length] of the vector to the length provided, without
  /// changing direction.
  ///
  /// If you try to scale the zero (empty) vector, it will remain unchanged, and
  /// no error will be thrown.
  void scaleTo(double newLength) {
    final l = length;
    if (l != 0) {
      scale(newLength.abs() / l);
    }
  }

  /// Clamps the [length] of this vector.
  ///
  /// This means that if the length is less than [min] the length will be set to
  /// [min] and if the length is larger than [max], the length will be set to
  /// [max]. If the length is in between [min] and [max], no changes will be
  /// made.
  void clampLength(double min, double max) {
    final lengthSquared = length2;
    if (lengthSquared > max * max) {
      scaleTo(max);
    } else if (lengthSquared < min * min) {
      scaleTo(min);
    }
  }

  /// Project this onto [other].
  ///
  /// [other] needs to have a length > 0;
  /// If [out] is specified, it will be used to provide the result.
  Vector2 projection(Vector2 other, {Vector2? out}) {
    assert(other.length2 > 0, 'other needs to have a length > 0');
    final dotProduct = dot(other);
    final result = (out?..setFrom(other)) ?? other.clone();
    return result..scale(dotProduct / other.length2);
  }

  /// Inverts the vector.
  void invert() {
    x *= -1;
    y *= -1;
  }

  /// Returns the inverse of this vector.
  Vector2 inverted() => Vector2(-x, -y);

  /// Smoothly moves this [Vector2] in the direction [target] by a displacement
  /// given by a distance [ds] in that direction.
  ///
  /// It does not goes beyond target, regardless of [ds], so the final value
  /// is always [target].
  ///
  /// Note: [ds] is the displacement vector in units of the vector space. It is
  /// **not** a percentage (relative value).
  void moveToTarget(
    Vector2 target,
    double ds,
  ) {
    if (this != target) {
      final diff = target - this;
      if (diff.length < ds) {
        setFrom(target);
      } else {
        diff.scaleTo(ds);
        setFrom(this + diff);
      }
    }
  }

  /// Signed angle in a coordinate system where the Y-axis is flipped.
  ///
  /// Since on a canvas/screen y is smaller the further up you go, instead of
  /// larger like on a normal coordinate system, to get an angle that is in that
  /// coordinate system we have to flip the Y-axis of the [Vector2].
  ///
  /// Example:
  /// Up: Vector(0.0, -1.0).screenAngle == 0
  /// Down: Vector(0.0, 1.0).screenAngle == +-pi
  /// Left: Vector(-1.0, 0.0).screenAngle == -pi/2
  /// Right: Vector(-1.0, 0.0).screenAngle == pi/2
  double screenAngle() => (clone()..y *= -1).angleToSigned(Vector2(0.0, 1.0));

  /// Modulo/Remainder
  Vector2 operator %(Vector2 mod) => Vector2(x % mod.x, y % mod.y);

  /// Create a Vector2 with ints as input
  static Vector2 fromInts(int x, int y) => Vector2(x.toDouble(), y.toDouble());

  /// Creates a heading [Vector2] with the given angle in radians.
  static Vector2 fromRadians(double r) => Vector2(0, -1)..rotate(r);

  /// Creates a heading [Vector2] with the given angle in degrees.
  static Vector2 fromDegrees(double d) => fromRadians(d * degrees2Radians);

  /// Creates a new identity [Vector2] (1.0, 1.0).
  static Vector2 identity() => Vector2.all(1.0);
}
