import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/line.dart';

/// A [LineSegment] represent a segment of an infinitely long line, it is the
/// segment between the [from] and [to] vectors (inclusive).
class LineSegment {
  final Vector2 from;
  final Vector2 to;

  LineSegment(this.from, this.to);

  factory LineSegment.zero() => LineSegment(Vector2.zero(), Vector2.zero());

  /// Returns an empty list if there are no intersections between the segments
  /// If the segments are concurrent, the intersecting point is returned as a
  /// list with a single point
  List<Vector2> intersections(LineSegment otherSegment) {
    final result = toLine().intersections(otherSegment.toLine());
    if (result.isNotEmpty) {
      // The lines are not parallel
      final intersection = result.first;
      if (containsPoint(intersection) &&
          otherSegment.containsPoint(intersection)) {
        // The intersection point is on both line segments
        return result;
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
        final sum = Vector2.zero();
        overlaps.forEach(sum.add);
        return [sum..scale(1 / overlaps.length)];
      }
    }
    return [];
  }

  bool containsPoint(Vector2 point, {double epsilon = 0.000001}) {
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
