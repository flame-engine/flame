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

  Position.fromPoint(math.Point point) : this(point.x, point.y);

  Position add(Position other) {
    this.x += other.x;
    this.y += other.y;
    return this;
  }

  Position opposite() {
    this.x *= -1;
    this.y *= -1;
    return this;
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

  math.Point toPoint() {
    return new math.Point(x, y);
  }
}
