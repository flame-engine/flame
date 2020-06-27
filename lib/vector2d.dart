import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:box2d_flame/box2d.dart' as b2d;

/// An ordered pair representation (point, position, offset, vector2).
///
/// It differs from the default implementations provided (math.Point and ui.Offset) as it's mutable.
/// Also, it offers helpful converters and a some useful methods for manipulation.
/// It always uses double values to store the coordinates.
class Vector2d {
  /// Coordinates
  double x, y;

  /// Basic constructor
  Vector2d(this.x, this.y);

  /// Creates a [Vector2d] with 0 splat into both lanes of the vector
  Vector2d.zero() : this(0.0, 0.0);

  /// Creates a [Vector2d] by converting integers to double.
  ///
  /// Internal representation is still using double, the conversion is made in the constructor only.
  Vector2d.fromInts(int x, int y) : this(x.toDouble(), y.toDouble());

  /// Creates a [Vector2d] using an [ui.Offset]
  Vector2d.fromOffset(ui.Offset offset) : this(offset.dx, offset.dy);

  /// Creates a [Vector2d] using an [ui.Size]
  Vector2d.fromSize(ui.Size size) : this(size.width, size.height);

  /// Creates a [Vector2d] using an [math.Point]
  Vector2d.fromPoint(math.Point point) : this(point.x, point.y);

  /// Clones a [Vector2d]
  ///
  /// This is useful because this class is mutable, so beware of mutability issues.
  Vector2d.fromVector2d(Vector2d position) : this(position.x, position.y);

  /// Creates a [Vector2d] using a [b2d.Vector2]
  Vector2d.fromVector2(b2d.Vector2 vector) : this(vector.x, vector.y);

  /// Adds the coordinates from another vector.
  void add(Vector2d other) {
    x += other.x;
    y += other.y;
  }

  /// Subtracts the coordinates from another vector.
  void minus(Vector2d other) {
    x -= other.x;
    y -= other.y;
  }

  /// Scales the vector by a factor [scalar]
  void scale(double scalar) {
    x *= scalar;
    y *= scalar;
  }

  /// Divides (scales down) by a factor [scalar]
  void div(double scalar) {
    scale(1 / scalar);
  }

  /// Vector multiplication
  void multiply(Vector2d vector) {
    x *= vector.x;
    y *= vector.y;
  }

  Vector2d opposite() {
    return clone()..scale(-1.0);
  }

  double dotProduct(Vector2d p) {
    return x * p.x + y * p.y;
  }

  /// The length (or magnitude) of this vector.
  double length() {
    return math.sqrt(dotProduct(this));
  }

  /// Rotate around origin; [angle] in radians.
  Vector2d rotate(double angle) {
    final double nx = math.cos(angle) * x - math.sin(angle) * y;
    final double ny = math.sin(angle) * x + math.cos(angle) * y;
    x = nx;
    y = ny;
    return this;
  }

  /// Rotate around origin; [angle] in degrees.
  Vector2d rotateDeg(double angle) {
    return rotate(angle * math.pi / 180);
  }

  /// Change current rotation by delta angle; [angle] in radians.
  Vector2d rotateDelta(double radians) {
    return rotate(angle() + radians);
  }

  /// Change current rotation by delta angle; [angle] in degrees.
  Vector2d rotateDeltaDeg(double degrees) {
    return rotateDeg(angleDeg() + degrees);
  }

  /// Returns the angle of this vector from origin in radians.
  double angle() {
    return math.atan2(y, x);
  }

  /// Returns the angle of this vector from origin in degrees.
  double angleDeg() {
    return angle() * 180 / math.pi;
  }

  /// Returns the angle of this vector from another [Vector2d] in radians.
  double angleFrom(Vector2d other) {
    // Technically the origin is not a vector so you cannot find the angle between
    // itself and another vector so just default to calculating the angle between
    // the non-origin point and the origin to avoid division by zero
    if (x == 0 && y == 0) {
      return other.angle();
    }
    if (other.x == 0 && other.y == 0) {
      return angle();
    }

    return math.acos(dotProduct(other) / (length() * other.length()));
  }

  /// Returns the angle of this vector from another [Vector2d] in degrees.
  double angleFromDeg(Vector2d other) {
    return angleFrom(other) * 180 / math.pi;
  }

  /// Returns the distance between two vectors
  double distance(Vector2d other) {
    return (this-other).length();
  }

  /// Changes the [length] of this vector to the one provided, without changing the direction.
  ///
  /// If you try to scale the zero (empty) vector, it will remain unchanged, and no error will be thrown.
  void scaleTo(double newLength) {
    final l = length();
    if (l == 0) {
      return;
    }
    scale(newLength.abs() / l);
  }

  /// Normalizes this vector, without changing direction.
  void normalize() {
    scaleTo(1.0);
  }

  /// Limits the [length] of this vector to the one provided, without changing direction.
  ///
  /// If this vector's length is bigger than [maxLength], it becomes [maxLength]; otherwise, nothing changes.
  void limit(double maxLength) {
    final newLength = length().clamp(0.0, maxLength.abs());
    scaleTo(newLength);
  }

  Vector2d clone() {
    return Vector2d.fromVector2d(this);
  }

  bool equals(Vector2d p) {
    return p.x == x && p.y == y;
  }

  @override
  bool operator ==(other) {
    return other is Vector2d && equals(other);
  }

  /// Negate.
  Vector2d operator -() => clone()..opposite();

  /// Subtract two vectors.
  Vector2d operator -(Vector2d other) => clone()..minus(other);

  /// Add two vectors.
  Vector2d operator +(Vector2d other) => clone()..add(other);

  /// Scale.
  Vector2d operator /(double scale) => clone()..div(scale);

  /// Scale.
  Vector2d operator *(double scale) => clone()..scale(scale);

  ui.Offset toOffset() {
    return ui.Offset(x, y);
  }

  ui.Size toSize() {
    return ui.Size(x, y);
  }

  math.Point toPoint() {
    return math.Point(x, y);
  }

  b2d.Vector2 toVector2() {
    return b2d.Vector2(x, y);
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    return '($x, $y)';
  }

  static ui.Rect rectFrom(Vector2d topLeft, Vector2d size) {
    return ui.Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
  }

  static ui.Rect bounds(List<Vector2d> pts) {
    final double minx = pts.map((e) => e.x).reduce(math.min);
    final double maxx = pts.map((e) => e.x).reduce(math.max);
    final double miny = pts.map((e) => e.y).reduce(math.min);
    final double maxy = pts.map((e) => e.y).reduce(math.max);
    return ui.Rect.fromPoints(ui.Offset(minx, miny), ui.Offset(maxx, maxy));
  }
}
