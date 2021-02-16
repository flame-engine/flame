import 'dart:math';
import 'dart:ui';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'shape.dart';

class Circle extends Shape {
  /// The [definition] is how many percentages of [size] that the circle should
  /// cover.
  double definition;

  Circle({
    this.definition = 1.0,
    Vector2 position,
    Vector2 size,
    double angle,
  }) : super(position: position, size: size, angle: angle = 0);

  /// With this helper method you can create your [Circle] from a radius and
  /// a position. This helper will also calculate the bounding rectangle [size]
  /// for the [Circle].
  factory Circle.fromRadius(
    double radius,
    Vector2 position, {
    double angle = 0,
  }) {
    return Circle(
      position: position,
      size: Vector2.all(radius * 2),
      angle: angle,
    );
  }

  double get radius {
    return (min(size.x, size.y) / 2) * definition;
  }

  @override
  void render(Canvas canvas, Paint paint) {
    canvas.drawCircle((size / 2 + position).toOffset(), radius, paint);
  }

  /// Checks whether the represented circle contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    return shapeCenter.distanceToSquared(point) < radius * radius;
  }

  /// Returns the locus of points in which the provided line segment intersect
  /// the circle.
  ///
  /// This can be an empty list (if they don't intersect)
  /// one point (if the line is tangent) or two points (if the line is secant).
  List<Vector2> lineSegmentIntersections(
    LineSegment line, {
    double epsilon = double.minPositive,
  }) {
    double sq(double x) => pow(x, 2).toDouble();

    final double cx = shapeCenter.x;
    final double cy = shapeCenter.y;

    final Vector2 point1 = line.from;
    final Vector2 point2 = line.to;

    final Vector2 delta = point2 - point1;

    final double A = sq(delta.x) + sq(delta.y);
    final double B =
        2 * (delta.x * (point1.x - cx) + delta.y * (point1.y - cy));
    final double C = sq(point1.x - cx) + sq(point1.y - cy) - sq(radius);

    final double det = B * B - 4 * A * C;
    final result = <Vector2>[];
    if (A <= epsilon || det < 0) {
      return [];
    } else if (det == 0) {
      final double t = -B / (2 * A);
      result.add(Vector2(point1.x + t * delta.x, point1.y + t * delta.y));
    } else {
      final double t1 = (-B + sqrt(det)) / (2 * A);
      final Vector2 i1 =
          Vector2(point1.x + t1 * delta.x, point1.y + t1 * delta.y);

      final double t2 = (-B - sqrt(det)) / (2 * A);
      final Vector2 i2 =
          Vector2(point1.x + t2 * delta.x, point1.y + t2 * delta.y);

      result.addAll([i1, i2]);
    }
    result.removeWhere((v) => !line.containsPoint(v));
    return result;
  }
}

class HitboxCircle extends Circle with HitboxShape {}
