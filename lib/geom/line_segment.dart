import 'dart:math' as math;

import 'package:flame/position.dart';

/// A finite line segment between two points in a 2D Euclidian space.
///
/// It uses the [Position] class to represent the end points (thefore it's a double/real line segment).
/// It can be also used to represent the infinite line that's an extension to this segment in some contexts.
/// If you provide two equal points, it will create an empty line, which will cause errors in most methods and operations, so beware.
class LineSegment {
  /// The ends of the line segments.
  ///
  /// These are used to define the segment unequivocally.
  /// There is no distinction between them.
  Position p1, p2;

  /// Constructs a new line segment from two points.
  LineSegment.fromPoints(this.p1, this.p2);

  /// Constructs a new line segment copying another segment.
  LineSegment.fromLineSegment(LineSegment other)
      : this.fromPoints(other.p1.clone(), other.p2.clone());

  /// Returns the x coordinate of the point [p1].
  double get x1 => p1.x;

  /// Returns the x coordinate of the point [p2].
  double get x2 => p2.x;

  /// Returns the y coordinate of the point [p1].
  double get y1 => p1.y;

  /// Returns the y coordinate of the point [p2].
  double get y2 => p2.y;

  /// Returns a value for the `a` parameter of the parametric equation for this line segment.
  ///
  /// The general parametric equation is of the form `ax + by + c = 0`.
  /// This of course is compatible with the other parameters, [b] and [c].
  double get a => y1 - y2;

  /// Returns a value for the `b` parameter of the parametric equation for this line segment.
  ///
  /// The general parametric equation is of the form `ax + by + c = 0`.
  /// This of course is compatible with the other parameters, [a] and [c].
  double get b => x2 - x1;

  /// Returns a value for the `c` parameter of the parametric equation for this line segment.
  ///
  /// The general parametric equation is of the form `ax + by + c = 0`.
  /// This of course is compatible with the other parameters, [a] and [b].
  double get c => (x1 - x2) * y1 + (y2 - y1) * x1;

  /// Returns whether this line segment is perfectly vertically alinged (parallel to the y-axis).
  ///
  /// This is equivalent to b == 0.
  bool get vertical => x1 == x2;

  /// Returns whether this line segment is perfectly horizontally alinged (parallel to the x-axis).
  ///
  /// This is equivalent to a == 0.
  bool get horizontal => y1 == y2;

  /// Returns whether this line segment contains the point [p] provided.
  ///
  /// This means that the point is co-aligned with the points [p1] and [p2] and also is within the segment.
  bool contains(Position p, {double epsilon = double.minPositive}) {
    final double diff = (p1.distance(p) + p.distance(p2)) - length;
    return diff.abs() <= epsilon;
  }

  /// Returns whether the extended line of this segment contains the point [p] provided.
  ///
  /// This means that the point is co-aligned with the points [p1] and [p2], regardless of it being within the actual segment or not.
  bool containsExtended(Position p, {double epsilon = double.minPositive}) {
    final double diff = a * p.x + b * p.y + c;
    return diff.abs() <= epsilon;
  }

  /// Returns the line segment foot of perpendicular of this line segment with respect to the point [p] provided.
  ///
  /// This is defined as the line segment `l` that is perpendicular to this extended line and contains the point [p].
  /// The resulting line `l` might not intercept this line segment, but will intercept this extended line segment.
  /// If the point `p` is co-aligned with this line, an empty line will be returned. This might cause some trouble.
  LineSegment footOfPerpendicularLineSegment(Position p) {
    return LineSegment.fromPoints(footOfPerpendicularPoint(p), p);
  }

  /// Returns the point foot of perpendicular of this line segment with respect to the point [p] provided.
  ///
  /// This is defined as the point `r` in this extended line such as the line `rp` is perpendicular to this line.
  /// The resulting point `r` might not be contained within the segment.
  Position footOfPerpendicularPoint(Position p) {
    final double t = -1 * (a * p.x + b * p.y + c) / (a * a + b * b);
    final double x = t * a + p.x;
    final double y = t * b + p.y;
    return Position(x, y);
  }

  /// Returns the y value for the given x, if exists. This won't work if the line is vertical.
  ///
  /// This won't check if the point is within the Segment (it considers this to be the extended Line).
  double y(double x) {
    return (a * x + c) / b;
  }

  /// Returns the x value for the given y, if exists. This won't work if the line is horizontal.
  ///
  /// This won't check if the point is within the Segment (it considers this to be the extended Line).
  double x(double y) {
    return (b * y + c) / a;
  }

  /// The angle this line makes with the horizontal (using atan2).
  double get angle => math.atan2(-a, b);

  /// Walk a [distance] across the line starting at point [p1], returning a new LineSegment.
  ///
  /// The point [p2] is cloned.
  LineSegment walkFromP1(double distance) {
    final double theta = angle;
    final double x = distance * math.cos(theta);
    final double y = distance * math.sin(theta);
    final Position delta = Position(x, y);
    return LineSegment.fromPoints(p1.add(delta), p2.clone());
  }

  /// Calculates the length of this segment, using the Position.distance method.
  ///
  /// This uses the Euclidian distance in a 2D flat plane.
  double get length => p1.distance(p2);

  /// Creates a copy of this line segment.
  LineSegment clone() => LineSegment.fromPoints(p1.clone(), p2.clone());

  @override
  String toString() => 'LineSegment(p1: $p1, p2: $p2)';
}
