import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/position.dart';

import 'circle.dart';
import 'int_position.dart';
import 'int_rect.dart';
import 'line_segment.dart';

/// This represents an axis-aligned rectangle in a 2D Euclidian space.
///
/// A rectangle is a quadrilateral polygon with 2 pairs of equal length sides and 4 right angles.
/// Axis-aligned means each side is parallel to one of the Cartesian axis.
/// A square is a particular case of Rectangle where [w] == [h].
/// It uses doubles to represent the coordinates.
/// It serves pretty much the same purpose as the [Rect] class from dart:ui, but it has an additional range of methods for geometry operations using the other classes on this package.
/// You can easily convert it to and from dart's [Rect] class.
class Rectangle {
  /// The coordinates and size of this rectangle, as doubles.
  double x, y, w, h;

  /// Creates a [Rectangle] providing it's coordinates (x and y) and dimenions (width and height), in this order.
  ///
  /// The acronym is for left, top, width and height.
  Rectangle.fromLTWH(this.x, this.y, this.w, this.h);

  /// Creates a [Rectangle] from a dart:ui's [Rect].
  Rectangle.fromRect(Rect rect)
      : this.fromLTWH(rect.left, rect.top, rect.width, rect.height);

  /// Creates a [Rectangle] from the [IntRect] class.
  ///
  /// It converts the integer parameters to doubles.
  Rectangle.fromIntRect(IntRect rect) {
    x = rect.left.toDouble();
    y = rect.top.toDouble();
    w = rect.width.toDouble();
    h = rect.height.toDouble();
  }

  /// Copies another [Rectangle] into a new instance.
  Rectangle.fromRectangle(Rectangle other) {
    x = other.x;
    y = other.y;
    w = other.w;
    h = other.h;
  }

  /// Creates a [Rectangle] providing its position [p] (top left corner) and its dimension [size].
  ///
  /// They are provided as [Position]'s intances (so doubles).
  Rectangle.fromPositions(Position p, Position size) {
    x = p.x;
    y = p.y;
    w = size.x;
    h = size.y;
  }

  /// Creates a [Rectangle] providing its position [p] (top left corner) and its dimension [size].
  ///
  /// They are provided as [IntPosition]'s intances and converted to double.
  Rectangle.fromIntPositions(IntPosition p, IntPosition size)
      : this.fromPositions(p.toPosition(), size.toPosition());

  /// Creates an empty [Rectangle] (that is, width and height equal to zero).
  ///
  /// By convention, operations that create empty [Rectangle]s use this to create all of them in the position (0, 0) (as it's irrelevant for empty rectangles).
  static Rectangle empty() => Rectangle.fromLTWH(0, 0, 0, 0);

  /// Returns whether this is empty or not (either width or height is zero).
  ///
  /// By convention, if it's empty, all parameters should be zero (though not mandatory).
  bool get isEmpty => w == 0 || h == 0;

  /// Returns the x coordinate of the left side of the rectangle.
  double get left => x;

  /// Returns the x coordinate of the right side of the rectangle.
  double get right => x + w;

  /// Returns the y coordinate of the top side of the rectangle.
  double get top => y;

  /// Returns the y coordinate of the bottom side of the rectangle.
  double get bottom => y + h;

  /// Synonym of [w], returns the width of this rectangle.
  double get width => w;

  /// Synonym of [h], returns the height of this rectangle.
  double get height => h;

  /// Returns whether this [Rectangle] overlaps another [Rectangle].
  ///
  /// This means that the intersection is non-empty.
  bool overlapsRectangle(Rectangle other) {
    return !intersection(other).isEmpty;
  }

  /// Returns the smallest [Rectangle] fully containing the union of this with the [other] [Rectangle].
  ///
  /// This is not a set union! The result of this method does contain the path union, but is an axis-aligned Rectangle, so it might be bigger than the strict union.
  Rectangle union(Rectangle other) {
    if (other.isEmpty) {
      return this;
    }
    if (isEmpty) {
      return other;
    }

    final double rxi = math.min(left, other.left);
    final double ryi = math.min(top, other.top);

    final double rxf = math.max(right, other.right);
    final double ryf = math.max(bottom, other.bottom);

    return Rectangle.fromLTWH(rxi, ryi, rxf - rxi, ryf - ryi);
  }

  Rectangle intersection(Rectangle other) {
    if (isEmpty || other.isEmpty) {
      return empty();
    }

    final double rxi = math.max(left, other.left);
    final double ryi = math.max(top, other.top);

    final double rxf = math.min(right, other.right);
    final double ryf = math.min(bottom, other.bottom);

    if (rxi >= rxf || ryi >= ryf) {
      return empty();
    }

    return Rectangle.fromLTWH(rxi, ryi, rxf - rxi, ryf - ryi);
  }

  Rect asRect() {
    if (isEmpty) {
      return const Rect.fromLTWH(0.0, 0.0, 0.0, 0.0);
    }
    return Rect.fromLTWH(left, top, width, height);
  }

  Position toLT() {
    return Position(x.toDouble(), y.toDouble());
  }

  Rectangle expand(double delta) {
    return expandLR(delta).expandTB(delta);
  }

  Rectangle expandTB(double delta) {
    y -= delta;
    h += 2 * delta;
    return this;
  }

  Rectangle expandLR(double delta) {
    return expandLeft(delta).expandRight(delta);
  }

  Rectangle expandLeft(double delta) {
    x -= delta;
    w += delta;
    return this;
  }

  Rectangle expandRight(double delta) {
    w += delta;
    return this;
  }

  bool containsPosition(Position p) {
    return (p.x >= x && p.x <= x + width) && (p.y >= y && p.y <= y + height);
  }

  bool containsIntPosition(IntPosition p) {
    return containsPosition(p.toPosition());
  }

  List<Position> corners() {
    return [
      Position(x, y),
      Position(x, y + height),
      Position(x + width, y + height),
      Position(x + width, y),
    ];
  }

  List<LineSegment> sides() {
    final List<Position> _corners = corners();
    return [
      LineSegment.fromPoints(_corners[0], _corners[1]),
      LineSegment.fromPoints(_corners[1], _corners[2]),
      LineSegment.fromPoints(_corners[2], _corners[3]),
      LineSegment.fromPoints(_corners[3], _corners[0]),
    ];
  }

  bool overlapsCircle(Circle circle) {
    final bool centerInRect = containsPosition(circle.center);
    final bool insersectSides =
        sides().any((s) => circle.containsLineSegment(s));
    return centerInRect || insersectSides;
  }

  @override
  String toString() => 'Rectangle(x: $x, y: $y, w: $w, h: $h)';
}
