import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// A [Hitbox] in the shape of a polygon.
class PolygonHitbox extends PolygonComponent with ShapeHitbox {
  PolygonHitbox(
    List<Vector2> vertices, {
    double? angle,
    Anchor? anchor,
  }) : super(
          vertices,
          angle: angle,
          anchor: anchor,
        );

  /// With this constructor you define the [PolygonHitbox] in relation to the
  /// [parentSize] of the hitbox.
  ///
  /// Example: `[[1.0, 0.0], [0.0, -1.0], [-1.0, 0.0], [0.0, 1.0]]`
  /// This will form a diamond shape within the bounding size box.
  /// NOTE: Always define your shape in a counter-clockwise fashion (in the
  /// screen coordinate system)
  PolygonHitbox.relative(
    List<Vector2> relation, {
    Vector2? position,
    required Vector2 parentSize,
    double angle = 0,
    Anchor? anchor,
  }) : super.relative(
          relation,
          position: position,
          parentSize: parentSize,
          angle: angle,
          anchor: anchor,
          shrinkToBounds: true,
        );

  @override
  void fillParent() {
    throw UnsupportedError(
      'Use the RectangleHitbox if you want to fill the parent',
    );
  }
}
