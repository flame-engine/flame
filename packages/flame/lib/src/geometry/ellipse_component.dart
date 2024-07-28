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

  @override
  void render(Canvas canvas) {
    if (renderShape) {
      if (hasPaintLayers) {
        for (final paint in paintLayers) {
          canvas.drawOval(
            Rect.fromCenter(
              center: _centerOffset,
              width: scaledWidth,
              height: scaledHeight,
            ),
            paint,
          );
        }
      } else {
        canvas.drawOval(
          Rect.fromCenter(
            center: _centerOffset,
            width: scaledWidth,
            height: scaledHeight,
          ),
          paint,
        );
      }
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    canvas.drawOval(
      Rect.fromCenter(
        center: _centerOffset,
        width: scaledWidth,
        height: scaledHeight,
      ),
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

  /// Returns the locus of points in which the provided line segment intersects
  /// the ellipse.
  ///
  /// This can be an empty list (if they don't intersect), one point (if the
  /// line is tangent) or two points (if the line is secant).
  /// An edge point of the [lineSegment] that originates on the edge of the
  /// ellipse doesn't count as an intersection.
  List<Vector2> lineSegmentIntersections(
    LineSegment lineSegment, {
    double epsilon = double.minPositive,
  }) {
    // A point on a line is `from + t*(to - from)`. We're trying to solve the
    // equation `‖point - center‖² == 1`. Or, denoting `Δ₂₁ = to - from`
    // and `Δ₁₀ = from - center`, the equation is `‖t*Δ₂₁ + Δ₁₀‖² == 1`.
    // Expanding the norm, this becomes a square equation in `t`:
    // `t²Δ₂₁² + 2tΔ₂₁Δ₁₀ + Δ₁₀² - 1 == 0`.
    _delta21
      ..setFrom(lineSegment.to)
      ..sub(lineSegment.from); // to - from
    _delta10
      ..setFrom(lineSegment.from)
      ..sub(absoluteCenter); // from - absoluteCenter

    final a = (_delta21.x / scaledWidth) * (_delta21.x / scaledWidth) +
        (_delta21.y / scaledHeight) * (_delta21.y / scaledHeight);
    final b = 2 *
        ((_delta21.x * _delta10.x) / (scaledWidth * scaledWidth) +
            (_delta21.y * _delta10.y) / (scaledHeight * scaledHeight));
    final c = (_delta10.x / scaledWidth) * (_delta10.x / scaledWidth) +
        (_delta10.y / scaledHeight) * (_delta10.y / scaledHeight) -
        1;

    return solveQuadratic(a, b, c)
        .where((t) => t > 0 && t <= 1)
        .map((t) => lineSegment.from.clone()..addScaled(_delta21, t))
        .toList();
  }

  static final Vector2 _delta21 = Vector2.zero();
  static final Vector2 _delta10 = Vector2.zero();
}
