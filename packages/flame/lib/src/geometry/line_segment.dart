import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/line.dart';

/// A [LineSegment] represent a segment of an infinitely long line, it is the
/// segment between the [from] and [to] vectors (inclusive).
class LineSegment {
  final Vector2 from;
  final Vector2 to;

  /// Creates a [LineSegment] given a start ([from]) point and an end ([to])
  /// point.
  LineSegment(this.from, this.to);

  /// Creates a [LineSegment] starting at a given a [start] point and following
  /// a certain [direction] for a given [length].
  LineSegment.withLength({
    required Vector2 start,
    required Vector2 direction,
    required double length,
  }) : this(start, start + direction.normalized() * length);

  factory LineSegment.zero() => LineSegment(Vector2.zero(), Vector2.zero());

  /// A unit vector representing the direction of the line segment.
  Vector2 get direction => (to - from)..normalize();

  /// The length of the line segment.
  double get length => (to - from).length;

  /// The point in the center of this line segment.
  Vector2 get midpoint => (from + to)..scale(0.5);

  /// Spreads points evenly along the line segment.
  /// A number of points [amount] are returned; the edges are not included.
  List<Vector2> spread(int amount) {
    if (amount < 0) {
      throw ArgumentError('Amount must be non-negative');
    }
    if (amount == 0) {
      return [];
    }

    final step = length / (amount + 1);
    return [
      for (var i = 1; i <= amount; i++) from + direction * (i * step),
    ];
  }

  /// Returns a new [LineSegment] translated by a given displacement [offset].
  LineSegment translate(Vector2 offset) {
    return LineSegment(from + offset, to + offset);
  }

  /// Returns a new [LineSegment] with same direction but extended by [amount]
  /// on both sides.
  LineSegment inflate(double amount) {
    final direction = this.direction;
    return LineSegment(from - direction * amount, to + direction * amount);
  }

  /// Returns a new [LineSegment] with same direction but reduced by [amount]
  /// on both sides.
  LineSegment deflate(double amount) {
    return inflate(-amount);
  }

  /// Returns an empty list if there are no intersections between the segments.
  /// If the segments intersect in a single point, that point is returned in a
  /// list with a single element.
  /// If the segments are collinear and overlap, the end points of the
  /// overlapping section are returned.
  List<Vector2> intersections(LineSegment otherSegment) {
    const epsilon = 0.01;
    final otherFrom = otherSegment.from;
    final otherTo = otherSegment.to;
    if (max(from.x, to.x) + epsilon < min(otherFrom.x, otherTo.x) ||
        min(from.x, to.x) - epsilon > max(otherFrom.x, otherTo.x) ||
        max(from.y, to.y) + epsilon < min(otherFrom.y, otherTo.y) ||
        min(from.y, to.y) - epsilon > max(otherFrom.y, otherTo.y)) {
      return const [];
    }
    final a1 = to.y - from.y;
    final b1 = from.x - to.x;
    final c1 = to.y * from.x - from.y * to.x;
    final a2 = otherTo.y - otherFrom.y;
    final b2 = otherFrom.x - otherTo.x;
    final c2 = otherTo.y * otherFrom.x - otherFrom.y * otherTo.x;
    final determinant = a1 * b2 - a2 * b1;
    if (determinant != 0) {
      // The lines are not parallel
      final intersection = Vector2(
        (b2 * c1 - b1 * c2) / determinant,
        (a1 * c2 - a2 * c1) / determinant,
      );
      if (containsPoint(intersection) &&
          otherSegment.containsPoint(intersection)) {
        // The intersection point is on both line segments
        return [intersection];
      }
    } else {
      // In here we know that the lines are parallel
      final overlaps = {
        if (otherSegment.containsPoint(from)) from,
        if (otherSegment.containsPoint(to)) to,
        if (containsPoint(otherSegment.from)) otherSegment.from,
        if (containsPoint(otherSegment.to)) otherSegment.to,
      };
      if (overlaps.isNotEmpty) {
        return overlaps.toList(growable: false);
      }
    }
    return const [];
  }

  /// Whether the given [point] lies in this line segment.
  bool containsPoint(Vector2 point, {double epsilon = 0.01}) {
    final delta = to - from;
    final crossProduct =
        (point.y - from.y) * delta.x - (point.x - from.x) * delta.y;

    // compare versus epsilon for floating point values
    if (crossProduct.abs() > epsilon) {
      return false;
    }

    final dotProduct =
        (point.x - from.x) * delta.x + (point.y - from.y) * delta.y;
    if (dotProduct < 0) {
      return false;
    }

    final squaredLength = from.distanceToSquared(to);
    if (dotProduct > squaredLength) {
      return false;
    }

    return true;
  }

  bool pointsAt(Line line) {
    final result = toLine().intersections(line);
    if (result.isNotEmpty) {
      final delta = to - from;
      final intersection = result.first;
      final intersectionDelta = intersection - to;
      // Whether the two points [from] and [through] forms a ray that points on
      // the line represented by this object
      if (delta.x.sign == intersectionDelta.x.sign &&
          delta.y.sign == intersectionDelta.y.sign) {
        return true;
      }
    }
    return false;
  }

  Line toLine() => Line.fromPoints(from, to);

  @override
  String toString() {
    return '[$from, $to]';
  }
}
