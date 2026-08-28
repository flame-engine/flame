import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset, Size;

import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/game/notifying_vector2.dart';

/// An immutable 2D vector that is free to create and combine.
///
/// [VectorValue] is an extension type over [Float64x2], which the Dart VM keeps
/// unboxed in locals, arguments, return values and non-nullable fields. As a
/// result, a whole expression such as
///
/// ```dart
/// position.value = size.value / 2 + offset + velocity * dt;
/// ```
///
/// runs without allocating a single object, whereas the same expression with
/// [Vector2] allocates one vector (and its [Float32List]) per operator.
///
/// [VectorValue] is the value counterpart of the mutable [Vector2]: use
/// [VectorValue] for math, and [Vector2] (or [NotifyingVector2]) as storage
/// that can be observed and modified in place. The two are bridged by
/// [Vector2Extension.value]:
///
/// ```dart
/// final VectorValue direction = (target.value - position.value).normalized();
/// position.value += direction * speed * dt;
/// ```
///
/// Every member is marked `@pragma('vm:prefer-inline')` because the
/// allocation-free behavior relies on the operators being inlined into the
/// caller. Do not remove the pragmas.
///
/// Because extension types cannot declare `==` or `hashCode`, the `==`
/// operator on a [VectorValue] compares by identity, like [Float64x2] does.
/// Use [equals] or [closeTo] to compare values, and do not use [VectorValue]
/// as a map key.
extension type VectorValue._(Float64x2 _v) {
  /// Creates a vector with the given components.
  @pragma('vm:prefer-inline')
  VectorValue(double x, double y) : _v = Float64x2(x, y);

  /// Creates a vector with both components set to [value].
  @pragma('vm:prefer-inline')
  VectorValue.all(double value) : _v = Float64x2.splat(value);

  /// Creates a vector with the components of [vector].
  @pragma('vm:prefer-inline')
  VectorValue.fromVector2(Vector2 vector) : _v = Float64x2(vector.x, vector.y);

  /// Creates a vector from an [Offset].
  @pragma('vm:prefer-inline')
  VectorValue.fromOffset(Offset offset) : _v = Float64x2(offset.dx, offset.dy);

  /// Creates a vector from a [Size].
  @pragma('vm:prefer-inline')
  VectorValue.fromSize(Size size) : _v = Float64x2(size.width, size.height);

  /// Creates a unit vector pointing in the direction of [radians], where 0
  /// points up (negative y) and positive angles rotate clockwise on screen,
  /// matching [Vector2Extension.fromRadians].
  @pragma('vm:prefer-inline')
  VectorValue.fromRadians(double radians)
    : _v = Float64x2(math.sin(radians), -math.cos(radians));

  /// The vector (0, 0).
  static final VectorValue zero = VectorValue(0, 0);

  /// The vector (1, 1).
  static final VectorValue one = VectorValue(1, 1);

  /// The x component.
  @pragma('vm:prefer-inline')
  double get x => _v.x;

  /// The y component.
  @pragma('vm:prefer-inline')
  double get y => _v.y;

  /// A copy of this vector with the x component replaced by [x].
  @pragma('vm:prefer-inline')
  VectorValue withX(double x) => VectorValue._(_v.withX(x));

  /// A copy of this vector with the y component replaced by [y].
  @pragma('vm:prefer-inline')
  VectorValue withY(double y) => VectorValue._(_v.withY(y));

  /// Component-wise sum.
  @pragma('vm:prefer-inline')
  VectorValue operator +(VectorValue other) => VectorValue._(_v + other._v);

  /// Component-wise difference.
  @pragma('vm:prefer-inline')
  VectorValue operator -(VectorValue other) => VectorValue._(_v - other._v);

  /// Negation.
  @pragma('vm:prefer-inline')
  VectorValue operator -() => VectorValue._(-_v);

  /// Scales both components by [factor].
  @pragma('vm:prefer-inline')
  VectorValue operator *(double factor) => VectorValue._(_v.scale(factor));

  /// Divides both components by [divisor].
  @pragma('vm:prefer-inline')
  VectorValue operator /(double divisor) =>
      VectorValue._(_v.scale(1 / divisor));

  /// Component-wise product.
  @pragma('vm:prefer-inline')
  VectorValue multiplied(VectorValue other) => VectorValue._(_v * other._v);

  /// Component-wise quotient.
  @pragma('vm:prefer-inline')
  VectorValue divided(VectorValue other) => VectorValue._(_v / other._v);

  /// The dot product with [other].
  @pragma('vm:prefer-inline')
  double dot(VectorValue other) {
    final product = _v * other._v;
    return product.x + product.y;
  }

  /// The 2D cross product (the z component of the 3D cross product).
  @pragma('vm:prefer-inline')
  double cross(VectorValue other) => x * other.y - y * other.x;

  /// The squared length of the vector.
  @pragma('vm:prefer-inline')
  double get length2 => dot(this);

  /// The length of the vector.
  @pragma('vm:prefer-inline')
  double get length => math.sqrt(length2);

  /// Whether both components are zero.
  @pragma('vm:prefer-inline')
  bool get isZero => x == 0 && y == 0;

  /// Whether both components are finite.
  @pragma('vm:prefer-inline')
  bool get isFinite => x.isFinite && y.isFinite;

  /// The vector with the same direction and length 1. The zero vector is
  /// returned unchanged.
  @pragma('vm:prefer-inline')
  VectorValue normalized() {
    final l = length;
    return l == 0 ? this : VectorValue._(_v.scale(1 / l));
  }

  /// The vector with the same direction and length [newLength]. The zero
  /// vector is returned unchanged.
  @pragma('vm:prefer-inline')
  VectorValue withLength(double newLength) {
    final l = length;
    return l == 0 ? this : VectorValue._(_v.scale(newLength.abs() / l));
  }

  /// The vector with its length clamped to the range [min] to [max].
  @pragma('vm:prefer-inline')
  VectorValue withLengthClamped(double min, double max) {
    final l2 = length2;
    if (l2 > max * max) {
      return withLength(max);
    }
    if (l2 < min * min) {
      return withLength(min);
    }
    return this;
  }

  /// The vector perpendicular to this one, rotated a quarter turn clockwise
  /// on screen (positive y down).
  @pragma('vm:prefer-inline')
  VectorValue perpendicular() => VectorValue(-y, x);

  /// The distance to [other].
  @pragma('vm:prefer-inline')
  double distanceTo(VectorValue other) => (this - other).length;

  /// The squared distance to [other].
  @pragma('vm:prefer-inline')
  double distanceToSquared(VectorValue other) => (this - other).length2;

  /// Linear interpolation towards [to] by the fraction [t].
  @pragma('vm:prefer-inline')
  VectorValue lerp(VectorValue to, double t) => this + (to - this) * t;

  /// The vector rotated by [angle] radians around [center] (the origin by
  /// default). On screen, where the y axis points down, positive angles rotate
  /// clockwise, matching [Vector2Extension.rotate].
  @pragma('vm:prefer-inline')
  VectorValue rotated(double angle, {VectorValue? center}) {
    if (angle == 0) {
      return this;
    }
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    if (center == null) {
      return VectorValue(x * cos - y * sin, x * sin + y * cos);
    }
    final dx = x - center.x;
    final dy = y - center.y;
    return VectorValue(
      cos * dx - sin * dy + center.x,
      sin * dx + cos * dy + center.y,
    );
  }

  /// The unsigned angle in radians between this vector and [other], in the
  /// range 0 to π.
  @pragma('vm:prefer-inline')
  double angleTo(VectorValue other) {
    final denominator = math.sqrt(length2 * other.length2);
    if (denominator == 0) {
      return 0;
    }
    return math.acos((dot(other) / denominator).clamp(-1.0, 1.0));
  }

  /// The signed angle in radians from this vector to [other], in the range
  /// -π to π. Positive when [other] is clockwise from this vector on screen.
  @pragma('vm:prefer-inline')
  double angleToSigned(VectorValue other) =>
      math.atan2(cross(other), dot(other));

  /// The angle of this vector in a screen coordinate system where (0, -1)
  /// points up and has angle 0, matching [Vector2Extension.screenAngle].
  @pragma('vm:prefer-inline')
  double get screenAngle => math.atan2(x, -y);

  /// Component-wise absolute value.
  @pragma('vm:prefer-inline')
  VectorValue abs() => VectorValue._(_v.abs());

  /// Component-wise minimum with [other].
  @pragma('vm:prefer-inline')
  VectorValue min(VectorValue other) => VectorValue._(_v.min(other._v));

  /// Component-wise maximum with [other].
  @pragma('vm:prefer-inline')
  VectorValue max(VectorValue other) => VectorValue._(_v.max(other._v));

  /// Component-wise clamp between [lower] and [upper].
  @pragma('vm:prefer-inline')
  VectorValue clamp(VectorValue lower, VectorValue upper) =>
      VectorValue._(_v.clamp(lower._v, upper._v));

  /// Both components rounded down.
  @pragma('vm:prefer-inline')
  VectorValue floor() => VectorValue(x.floorToDouble(), y.floorToDouble());

  /// Both components rounded up.
  @pragma('vm:prefer-inline')
  VectorValue ceil() => VectorValue(x.ceilToDouble(), y.ceilToDouble());

  /// Both components rounded to the nearest integer.
  @pragma('vm:prefer-inline')
  VectorValue round() => VectorValue(x.roundToDouble(), y.roundToDouble());

  /// Whether this vector has exactly the same components as [other].
  ///
  /// Use this instead of `==`, which compares by identity.
  @pragma('vm:prefer-inline')
  bool equals(VectorValue other) => x == other.x && y == other.y;

  /// Whether every component of this vector is within [epsilon] of the
  /// corresponding component of [other].
  @pragma('vm:prefer-inline')
  bool closeTo(VectorValue other, {double epsilon = 1e-9}) =>
      (x - other.x).abs() <= epsilon && (y - other.y).abs() <= epsilon;

  /// Copies the components into [target], notifying its listeners if it is a
  /// [NotifyingVector2]. This does not allocate.
  @pragma('vm:prefer-inline')
  void copyInto(Vector2 target) => target.setValues(x, y);

  /// Creates a new mutable [Vector2] with these components.
  Vector2 toVector2() => Vector2(x, y);

  /// Creates an [Offset] with these components.
  @pragma('vm:prefer-inline')
  Offset toOffset() => Offset(x, y);

  /// Creates a [Size] with these components.
  @pragma('vm:prefer-inline')
  Size toSize() => Size(x, y);

  /// A readable representation, since `toString` cannot be overridden on an
  /// extension type and would print the underlying [Float64x2].
  String describe() => 'VectorValue($x, $y)';
}
