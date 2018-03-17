import 'dart:math' as math;
import 'dart:ui' as ui;

/*
 * An ordered pair representation (point, position, offset).
 * It differs from the default implementations provided (math.Point and ui.Offset) as it's mutable.
 * Also, it offers helpful converters and a some useful methods for manipulation.
 */
class Position {
  double x, y;

  Position(this.x, this.y);

  Position.empty() : this(0.0, 0.0);

  Position.fromOffset(ui.Offset offset) : this(offset.dx, offset.dy);

  Position.fromSize(ui.Size size) : this(size.width, size.height);

  Position.fromPoint(math.Point point) : this(point.x, point.y);

  Position.fromPosition(Position position) : this(position.x, position.y);

  Position add(Position other) {
    this.x += other.x;
    this.y += other.y;
    return this;
  }

  Position minus(Position other) {
    return this.add(other.clone().opposite());
  }

  Position opposite() {
    return this.times(-1.0);
  }

  Position times(double scalar) {
    this.x *= scalar;
    this.y *= scalar;
    return this;
  }

  double dotProduct(Position p) {
    return this.x * p.x + this.y * p.y;
  }

  double length() {
    return math.sqrt(math.pow(this.x, 2) + math.pow(this.y, 2));
  }

  Position rotate(double angle) {
    double nx = math.cos(angle) * this.x - math.sin(angle) * this.y;
    double ny = math.sin(angle) * this.x + math.cos(angle) * this.y;
    this.x = nx;
    this.y = ny;
    return this;
  }

  ui.Offset toOffset() {
    return new ui.Offset(x, y);
  }

  ui.Size toSize() {
    return new ui.Size(x, y);
  }

  math.Point toPoint() {
    return new math.Point(x, y);
  }

  Position clone() {
    return new Position.fromPosition(this);
  }

  @override
  String toString() {
    return "($x, $y)";
  }

  static ui.Rect rectFrom(Position topLeft, Position size) {
    return new ui.Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
  }
}
