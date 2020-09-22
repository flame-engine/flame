import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:box2d_flame/box2d.dart' as b2d;

/// An ordered pair representation (point, position, offset).
///
/// It differs from the default implementations provided (math.Point and ui.Offset) as it's mutable.
/// Also, it offers helpful converters and a some useful methods for manipulation.
/// It always uses double values to store the coordinates.
class Position {
  /// Coordinates
  double x, y;

  /// Basic constructor
  Position(this.x, this.y);

  /// Creates a point at the origin
  Position.empty() : this(0.0, 0.0);

  /// Creates converting integers to double.
  ///
  /// Internal representation is still using double, the conversion is made in the constructor only.
  Position.fromInts(int x, int y) : this(x.toDouble(), y.toDouble());

  /// Creates using an [ui.Offset]
  Position.fromOffset(ui.Offset offset) : this(offset.dx, offset.dy);

  /// Creates using an [ui.Size]
  Position.fromSize(ui.Size size) : this(size.width, size.height);

  /// Creates using an [math.Point]
  Position.fromPoint(math.Point point) : this(point.x, point.y);

  /// Creates using another [Position]; i.e., clones this position.
  ///
  /// This is useful because this class is mutable, so beware of mutability issues.
  Position.fromPosition(Position position) : this(position.x, position.y);

  /// Creates using a [b2d.Vector2]
  Position.fromVector(b2d.Vector2 vector) : this(vector.x, vector.y);

  /// Adds the coordinates from another vector.
  ///
  /// This method changes `this` instance and returns itself.
  Position add(Position other) {
    x += other.x;
    y += other.y;
    return this;
  }

  /// Substracts the coordinates from another vector.
  ///
  /// This method changes `this` instance and returns itself.
  Position minus(Position other) {
    return add(other.clone().opposite());
  }

  Position times(double scalar) {
    x *= scalar;
    y *= scalar;
    return this;
  }

  Position opposite() {
    return times(-1.0);
  }

  Position div(double scalar) {
    return times(1 / scalar);
  }

  double dotProduct(Position p) {
    return x * p.x + y * p.y;
  }

  /// The length (or magnitude) of this vector.
  double length() {
    return math.sqrt(dotProduct(this));
  }

  /// Rotate around origin; [angle] in radians.
  Position rotate(double angle) {
    final double nx = math.cos(angle) * x - math.sin(angle) * y;
    final double ny = math.sin(angle) * x + math.cos(angle) * y;
    x = nx;
    y = ny;
    return this;
  }

  /// Rotate around origin; [angle] in degrees.
  Position rotateDeg(double angle) {
    return rotate(angle * math.pi / 180);
  }

  /// Change current rotation by delta angle; [angle] in radians.
  Position rotateDelta(double radians) {
    return rotate(angle() + radians);
  }

  /// Change current rotation by delta angle; [angle] in degrees.
  Position rotateDeltaDeg(double degrees) {
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

  /// Returns the angle of this vector from another [Position] in radians.
  double angleFrom(Position other) {
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

  /// Returns the angle of this vector from another [Position] in degrees.
  double angleFromDeg(Position other) {
    return angleFrom(other) * 180 / math.pi;
  }

  double distance(Position other) {
    return clone().minus(other).length();
  }

  /// Changes the [length] of this vector to the one provided, without chaning direction.
  ///
  /// If you try to scale the zero (empty) vector, it will remain unchanged, and no error will be thrown.
  Position scaleTo(double newLength) {
    final l = length();
    if (l == 0) {
      return this;
    }
    return times(newLength.abs() / l);
  }

  /// Normalizes this vector, without changing direction.
  Position normalize() {
    return scaleTo(1.0);
  }

  /// Limits the [length] of this vector to the one provided, without changing direction.
  ///
  /// If this vector's length is bigger than [maxLength], it becomes [maxLength]; otherwise, nothing changes.
  Position limit(double maxLength) {
    final newLength = length().clamp(0.0, maxLength.abs());
    return scaleTo(newLength);
  }

  ui.Offset toOffset() {
    return ui.Offset(x, y);
  }

  ui.Size toSize() {
    return ui.Size(x, y);
  }

  math.Point toPoint() {
    return math.Point(x, y);
  }

  b2d.Vector2 toVector() {
    return b2d.Vector2(x, y);
  }

  Position clone() {
    return Position.fromPosition(this);
  }

  bool equals(Position p) {
    return p.x == x && p.y == y;
  }

  @override
  bool operator ==(other) {
    return other is Position && equals(other);
  }

  /// Negate.
  Position operator -() => clone()..opposite();

  /// Subtract two vectors.
  Position operator -(Position other) => clone()..minus(other);

  /// Add two vectors.
  Position operator +(Position other) => clone()..add(other);

  /// Scale.
  Position operator /(double scale) => clone()..div(scale);

  /// Scale.
  Position operator *(double scale) => clone()..times(scale);

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    return '($x, $y)';
  }

  static ui.Rect rectFrom(Position topLeft, Position size) {
    return ui.Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
  }

  static ui.Rect bounds(List<Position> pts) {
    final double minx = pts.map((e) => e.x).reduce(math.min);
    final double maxx = pts.map((e) => e.x).reduce(math.max);
    final double miny = pts.map((e) => e.y).reduce(math.min);
    final double maxy = pts.map((e) => e.y).reduce(math.max);
    return ui.Rect.fromPoints(ui.Offset(minx, miny), ui.Offset(maxx, maxy));
  }
}
