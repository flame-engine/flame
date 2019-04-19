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

  Position add(Position other) {
    x += other.x;
    y += other.y;
    return this;
  }

  Position minus(Position other) {
    return add(other.clone().opposite());
  }

  Position opposite() {
    return times(-1.0);
  }

  Position times(double scalar) {
    x *= scalar;
    y *= scalar;
    return this;
  }

  double dotProduct(Position p) {
    return x * p.x + y * p.y;
  }

  double length() {
    return math.sqrt(math.pow(x, 2) + math.pow(y, 2));
  }

  Position rotate(double angle) {
    final double nx = math.cos(angle) * x - math.sin(angle) * y;
    final double ny = math.sin(angle) * x + math.cos(angle) * y;
    x = nx;
    y = ny;
    return this;
  }

  double distance(Position other) {
    return minus(other).length();
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
