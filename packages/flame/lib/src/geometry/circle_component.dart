import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/effects/provider_interfaces.dart';

class CircleComponent extends ShapeComponent implements SizeProvider {
  /// With this constructor you can create your [CircleComponent] from a radius
  /// and a position. It will also calculate the bounding rectangle [size] for
  /// the [CircleComponent].
  CircleComponent({
    double? radius,
    Vector2? position,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
    Paint? paint,
  }) : super(
          position: position,
          size: Vector2.all((radius ?? 0) * 2),
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
          paint: paint,
        );

  /// With this constructor you define the [CircleComponent] in relation to the
  /// [parentSize]. For example having a [relation] of 0.5 would create a circle
  /// that fills half of the [parentSize].
  CircleComponent.relative(
    double relation, {
    Vector2? position,
    required Vector2 parentSize,
    double angle = 0,
    Anchor? anchor,
  }) : this(
          radius: relation * (min(parentSize.x, parentSize.y) / 2),
          position: position,
          angle: angle,
          anchor: anchor,
        );

  /// Get the radius of the circle before scaling.
  double get radius {
    return min(size.x, size.y) / 2;
  }

  /// Set the radius of the circle (and therefore the [size]).
  set radius(double value) {
    size.setValues(value * 2, value * 2);
  }

  // Used to not create new Vector2 objects every time radius is called.
  final Vector2 _scaledSize = Vector2.zero();

  /// Get the radius of the circle after it has been sized and scaled.
  double get scaledRadius {
    _scaledSize
      ..setFrom(size)
      ..multiply(absoluteScale);
    return min(_scaledSize.x, _scaledSize.y) / 2;
  }

  @override
  void render(Canvas canvas) {
    if (renderShape) {
      canvas.drawCircle((size / 2).toOffset(), radius, paint);
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    canvas.drawCircle((size / 2).toOffset(), radius, debugPaint);
  }

  /// Checks whether the represented circle contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    final scaledRadius = this.scaledRadius;
    return absoluteCenter.distanceToSquared(point) <
        scaledRadius * scaledRadius;
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final radius = size.x / 2;
    final dx = point.x - radius;
    final dy = point.y - radius;
    return dx * dx + dy * dy <= radius * radius;
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
    double sq(double x) => x * x;

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
