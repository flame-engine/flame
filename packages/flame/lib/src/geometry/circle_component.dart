import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/utils/solve_quadratic.dart';

class CircleComponent extends ShapeComponent implements SizeProvider {
  /// With this constructor you can create your [CircleComponent] from a radius
  /// and a position. It will also calculate the bounding rectangle [size] for
  /// the [CircleComponent].
  CircleComponent({
    double? radius,
    super.position,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.paint,
  }) : super(
          size: Vector2.all((radius ?? 0) * 2),
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

  /// Returns the locus of points in which the provided line segment intersects
  /// the circle.
  ///
  /// This can be an empty list (if they don't intersect), one point (if the
  /// line is tangent) or two points (if the line is secant).
  List<Vector2> lineSegmentIntersections(
    LineSegment line, {
    double epsilon = double.minPositive,
  }) {
    // A point on a line is `from + t*(to - from)`. We're trying to solve the
    // equation `‖point - center‖² == radius²`. Or, denoting `Δ₂₁ = to - from`
    // and `Δ₁₀ = from - center`, the equation is `‖t*Δ₂₁ + Δ₁₀‖² == radius²`.
    // Expanding the norm, this becomes a square equation in `t`:
    // `t²Δ₂₁² + 2tΔ₂₁Δ₁₀ + Δ₁₀² - radius² == 0`.
    _delta21
      ..setFrom(line.to)
      ..sub(line.from); // to - from
    _delta10
      ..setFrom(line.from)
      ..sub(absoluteCenter); // from - absoluteCenter
    final a = _delta21.length2;
    final b = 2 * _delta21.dot(_delta10);
    final c = _delta10.length2 - radius * radius;

    return solveQuadratic(a, b, c)
        .where((t) => t >= 0 && t <= 1)
        .map((t) => line.from.clone()..addScaled(_delta21, t))
        .toList();
  }

  static final Vector2 _delta21 = Vector2.zero();
  static final Vector2 _delta10 = Vector2.zero();
}
