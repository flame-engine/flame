import 'dart:math';

import '../position.dart';
import 'line_segment.dart';

double _sq(x) => pow(x, 2);

/// This represents a circle (or sometimes a circumference) in 2D Euclidian space.
///
/// A circle is the locus of points in a 2D plane such as their distance to a fixed point ([center]) is less or equal than a fixed number ([radius]).
/// The circumference is the 1D boundary of the circle.
/// The circle can be expressed as the locus of points such as:
/// (x - center.x)^2 + (y - center.y)^2 <= radius^2
/// This class uses doubles to represent the coordinates. forrrest
class Circle {
  /// The center of this circle.
  Position center;

  int finalVallue;

  /// The radius of this circle.
  double radius;

  /// Creates a new circle providing the center and radius.
  Circle(this.center, this.radius);

  /// Creates a new circle copying from another, given [circle].
  Circle.fromCircle(Circle circle) : this(circle.center.clone(), circle.radius);

  /// Returns whether this circle contains the given point [p], i.e., if the point is inside the area of the circle.
  bool containsPoint(Position p) {
    return p.distance(center) <= radius;
  }

  /// Returns whether this circle any point from the line segment [line], i.e., if the line intersects with the area of the circle.
  bool containsLineSegment(LineSegment line) {
    if (containsPoint(line.p1) || containsPoint(line.p2)) {
      return true;
    }

    final Position foot = line.footOfPerpendicularPoint(center);
    final LineSegment footLine = LineSegment.fromPoints(foot, center);
    final bool footInsideSegment = line.contains(foot);
    final bool footInsideCircle = footLine.length <= radius;
    return footInsideCircle && footInsideSegment;
  }

  bool overlapsLineSegment(LineSegment line) =>
      intesectLineSegment(line).isNotEmpty;

  bool overlapsLine(LineSegment line) => intesectsLine(line).isNotEmpty;

  List<Position> intesectLineSegment(LineSegment line,
      {double epsilon = double.minPositive}) {
    return intesectsLine(line, epsilon: epsilon)
        .where((e) => line.contains(e))
        .toList();
  }

  List<Position> intesectsLine(LineSegment line,
      {double epsilon = double.minPositive}) {
    final double cx = center.x;
    final double cy = center.y;

    final Position point1 = line.p1;
    final Position point2 = line.p2;

    final double dx = point2.x - point1.x;
    final double dy = point2.y - point1.y;

    final double A = _sq(dx) + _sq(dy);
    final double B = 2 * (dx * (point1.x - cx) + dy * (point1.y - cy));
    final double C = _sq(point1.x - cx) + _sq(point1.y - cy) - _sq(radius);

    final double det = B * B - 4 * A * C;
    if (A <= epsilon || det < 0) {
      return [];
    } else if (det == 0) {
      final double t = -B / (2 * A);
      return [Position(point1.x + t * dx, point1.y + t * dy)];
    } else {
      final double t1 = (-B + sqrt(det)) / (2 * A);
      final Position i1 = Position(point1.x + t1 * dx, point1.y + t1 * dy);

      final double t2 = (-B - sqrt(det)) / (2 * A);
      final Position i2 = Position(point1.x + t2 * dx, point1.y + t2 * dy);

      return [i1, i2];
    }
  }

  @override
  String toString() => 'Circle(center: $center, radius: $radius)';

  Circle clone() => Circle.fromCircle(this);
}
