import 'linear_function.dart';
import '../../extensions.dart';

class LineSegment {
  final Vector2 from;
  final Vector2 to;

  LineSegment(this.from, this.to);

  /// If the line segment is outside of the hitbox
  bool isOutside(List<Vector2> hitbox) {
    for (int i = 0; i < hitbox.length; ++i) {
      if (intersections(LineSegment(hitbox[i], hitbox[(i + 1) % hitbox.length]))
          .isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Returns an empty list if there are no intersections
  /// If the segment overlap (not cross) the middle of the intersecting part is
  /// the result
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
      final overlaps = ({
        from: otherSegment.containsPoint(from),
        to: otherSegment.containsPoint(to),
        otherSegment.from: containsPoint(otherSegment.from),
        otherSegment.to: containsPoint(otherSegment.to),
      }..removeWhere((_key, onSegment) => !onSegment))
          .keys
          .toSet();
      if (overlaps.isNotEmpty) {
        return [
          overlaps.fold<Vector2>(Vector2.zero(), (sum, point) => sum + point) /
              overlaps.length.toDouble()
        ];
      }
    }
    return [];
  }

  bool containsPoint(Vector2 point) {
    const epsilon = 0.00001;
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

  bool pointsAt(LinearFunction line) {
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

  LinearFunction toLine() => LinearFunction.fromPoints(from, to);

  @override
  String toString() {
    return "[$from, $to]";
  }
}
