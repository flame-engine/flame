import 'dart:math';

import '../../components.dart';
import '../../extensions.dart';
import '../../geometry.dart';

class Circle extends Shape {
  double radius;

  /// With this constructor you can create your [Circle] from a radius and
  /// a position. It will also calculate the bounding rectangle [size] for the
  /// [Circle].
  Circle({
    required this.radius,
    Vector2? position,
    double? angle,
    int? priority,
  }) : super(
          position: position,
          size: Vector2.all(radius * 2),
          angle: angle,
          priority: priority,
        ) {
    size.addListener(() => radius = min(size.x, size.y) / 2);
  }

  /// This constructor is used by [HitboxCircle]
  ///
  /// [relation] is the relation `[0.0, 1.0]` of the shortest edge of [size]
  /// that the circle should fill.
  Circle.fromDefinition({
    double? relation,
    Vector2? position,
    Vector2? size,
    double? angle,
  })  : normalizedRadius = relation ?? 1.0,
        super(position: position, size: size, angle: angle ?? 0);

  // Used to not create new Vector2 objects every time radius is called.
  final Vector2 _scaledSize = Vector2.zero();

  /// Get the radius of the circle after it has been sized and scaled.
  double get scaledRadius {
    _scaledSize
      ..setFrom(size)
      ..multiply(scale);
    return min(_scaledSize.x, _scaledSize.y) / 2;
  }

  /// This render method doesn't rotate the canvas according to angle since a
  /// circle will look the same rotated as not rotated.
  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, paint);
  }

  /// Checks whether the represented circle contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    return absoluteCenter.distanceToSquared(point) < radius * radius;
  }

  /// Returns the locus of points in which the provided line segment intersect
  /// the circle.
  ///
  /// This can be an empty list (if they don't intersect), one point (if the
  /// line is tangent) or two points (if the line is secant).
  List<Vector2> lineSegmentIntersections(
    LineSegment line, {
    double epsilon = double.minPositive,
  }) {
    double sq(double x) => pow(x, 2).toDouble();

    final cx = absoluteCenter.x;
    final cy = absoluteCenter.y;

    final point1 = line.from;
    final point2 = line.to;

    final delta = point2 - point1;

    final A = sq(delta.x) + sq(delta.y);
    final B = 2 * (delta.x * (point1.x - cx) + delta.y * (point1.y - cy));
    final C = sq(point1.x - cx) + sq(point1.y - cy) - sq(radius);

    final det = B * B - 4 * A * C;
    final result = <Vector2>[];
    if (A <= epsilon || det < 0) {
      return [];
    } else if (det == 0) {
      final t = -B / (2 * A);
      result.add(Vector2(point1.x + t * delta.x, point1.y + t * delta.y));
    } else {
      final t1 = (-B + sqrt(det)) / (2 * A);
      final i1 = Vector2(
        point1.x + t1 * delta.x,
        point1.y + t1 * delta.y,
      );

      final t2 = (-B - sqrt(det)) / (2 * A);
      final i2 = Vector2(
        point1.x + t2 * delta.x,
        point1.y + t2 * delta.y,
      );

      result.addAll([i1, i2]);
    }
    result.removeWhere((v) => !line.containsPoint(v));
    return result;
  }
}

class HitboxCircle extends Circle with HasHitboxes, HitboxShape {
  HitboxCircle({
    double? normalizedRadius,
    Vector2? position,
    Vector2? size,
    double? angle,
  }) : super.fromDefinition(
          relation: normalizedRadius,
          position: position,
          size: size,
          angle: angle ?? 0,
        );
}
