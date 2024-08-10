import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/math/solve_quadratic.dart';
import 'package:meta/meta.dart';

class EllipseComponent extends ShapeComponent implements SizeProvider {
  /// Constructor to create an [EllipseComponent] from width and height.
  EllipseComponent({
    double? width,
    double? height,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.paint,
    super.paintLayers,
    super.key,
  }) : super(size: Vector2(width ?? 0, height ?? 0));

  /// Constructor to create an [EllipseComponent] relative to the parent size.
  /// The width and height are determined by
  /// [widthRelation] and [heightRelation]
  /// which are fractions of the parent's width and height.
  EllipseComponent.relative(
    double widthRelation,
    double heightRelation, {
    required Vector2 parentSize,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.paint,
    super.paintLayers,
    super.children,
    super.key,
  }) : super(
          size: Vector2(
            widthRelation * parentSize.x,
            heightRelation * parentSize.y,
          ),
        );

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    void updateCenterOffset() => _centerOffset = Offset(size.x / 2, size.y / 2);
    size.addListener(updateCenterOffset);
    updateCenterOffset();
  }

  late Offset _centerOffset;

  /// Get the width of the ellipse before scaling.
  @override
  double get width {
    return size.x;
  }

  /// Set the width of the ellipse (and therefore the [size]).
  @override
  set width(double value) {
    size.setValues(value, size.y);
  }

  /// Get the height of the ellipse before scaling.
  @override
  double get height {
    return size.y;
  }

  /// Set the height of the ellipse (and therefore the [size]).
  @override
  set height(double value) {
    size.setValues(size.x, value);
  }

  // Used to not create new Vector2 objects
  // every time scaledWidth or scaledHeight is called.
  final Vector2 _scaledSize = Vector2.zero();

  /// Get the width of the ellipse after it has been sized and scaled.
  double get scaledWidth {
    _scaledSize
      ..setFrom(size)
      ..multiply(absoluteScale);
    return _scaledSize.x;
  }

  /// Get the height of the ellipse after it has been sized and scaled.
  double get scaledHeight {
    _scaledSize
      ..setFrom(size)
      ..multiply(absoluteScale);
    return _scaledSize.y;
  }

  Rect _getRect() {
    return Rect.fromCenter(
      center: _centerOffset,
      width: scaledWidth,
      height: scaledHeight,
    );
  }

  @override
  void render(Canvas canvas) {
    if (renderShape) {
      if (hasPaintLayers) {
        for (final paint in paintLayers) {
          canvas.drawOval(
            _getRect(),
            paint,
          );
        }
      } else {
        canvas.drawOval(
          _getRect(),
          paint,
        );
      }
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    canvas.drawOval(
      _getRect(),
      debugPaint,
    );
  }

  /// Checks whether the represented ellipse contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    final scaledWidth = this.scaledWidth / 2;
    final scaledHeight = this.scaledHeight / 2;
    final dx = (point.x - absoluteCenter.x) / scaledWidth;
    final dy = (point.y - absoluteCenter.y) / scaledHeight;
    return dx * dx + dy * dy <= 1;
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final width = size.x / 2;
    final height = size.y / 2;
    final dx = (point.x - width) / width;
    final dy = (point.y - height) / height;
    return dx * dx + dy * dy <= 1;
  }

  /// Returns the locus of points where the provided line segment intersects
  /// the ellipse.
  ///
  /// This can be an empty list (if they don't intersect), one point (if the
  /// line is tangent), or two points (if the line is secant).
  /// An edge point of the [lineSegment] that lies exactly on the ellipse's edge
  /// might be considered as one intersection.
  List<Vector2> lineSegmentIntersections(
    LineSegment lineSegment, {
    double epsilon = double.minPositive,
  }) {
    // Calculate the semi-major (scaleX) and semi-minor (scaleY) axes
    // of the ellipse.
    // These represent half of the width and height, respectively.
    final scaleX = scaledWidth / 2;
    final scaleY = scaledHeight / 2;

    // Δ₂₁ represents the vector from the start to the end of the line segment:
    // Δ₂₁ = to - from.
    _delta21
      ..setFrom(lineSegment.to)
      ..sub(lineSegment.from);

    // Δ₁₀ represents the vector from the center of the ellipse to the start of
    // the line segment: Δ₁₀ = from - center.
    _delta10
      ..setFrom(lineSegment.from)
      ..sub(absoluteCenter);

    // Find the intersection points where the line segment meets the ellipse.
    // The equation of an ellipse centered at the origin is:
    // (x/scaleX)² + (y/scaleY)² = 1
    // Substituting the parametric equation of the line into this:
    // Let point = from + t*(to - from), then:
    // ((Δ₁₀.x + t*Δ₂₁.x) / scaleX)² + ((Δ₁₀.y + t*Δ₂₁.y) / scaleY)² = 1
    // Expanding and simplifying, we get a quadratic equation in t:
    final a = (_delta21.x * _delta21.x) / (scaleX * scaleX) +
        (_delta21.y * _delta21.y) / (scaleY * scaleY);
    final b = 2 *
        ((_delta21.x * _delta10.x) / (scaleX * scaleX) +
            (_delta21.y * _delta10.y) / (scaleY * scaleY));
    final c = (_delta10.x * _delta10.x) / (scaleX * scaleX) +
        (_delta10.y * _delta10.y) / (scaleY * scaleY) -
        1;

    // The roots of this quadratic equation give the values of t
    // where the line intersects the ellipse.
    final roots = solveQuadratic(a, b, c);

    // Filter roots to ensure they lie within the segment (0 <= t <= 1).
    // Use a set to avoid adding duplicate intersections,
    // which may occur in edge cases.
    final intersections = <Vector2>{};
    for (final t in roots) {
      if (t >= 0 && t <= 1) {
        // Calculate the intersection point corresponding to each valid t.
        final intersection = lineSegment.from + _delta21 * t;
        intersections.add(intersection);
      }
    }

    // Convert the set of intersections to a list and return.
    return intersections.toList();
  }

  static final Vector2 _delta21 = Vector2.zero();
  static final Vector2 _delta10 = Vector2.zero();
}
