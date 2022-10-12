// ignore_for_file: comment_references

import 'package:flame/collisions.dart';
import 'package:flame/geometry.dart';

/// A [Hitbox] in the shape of a polygon.
class PolygonHitbox extends PolygonComponent
    with ShapeHitbox, PolygonRayIntersection {
  PolygonHitbox(
    super.vertices, {
    super.position,
    super.angle,
    super.anchor,
    bool isSolid = false,
  }) {
    this.isSolid = isSolid;
  }

  /// With this constructor you define the [PolygonHitbox] in relation to the
  /// [parentSize] of the hitbox.
  ///
  /// Example: `[[1.0, 0.0], [0.0, -1.0], [-1.0, 0.0], [0.0, 1.0]]`
  /// This will form a diamond shape within the bounding size box.
  /// NOTE: Always define your shape in a counter-clockwise fashion (in the
  /// screen coordinate system)
  PolygonHitbox.relative(
    super.relation, {
    super.position,
    required super.parentSize,
    double super.angle = 0,
    super.anchor,
    bool isSolid = false,
  }) : super.relative(
          shrinkToBounds: true,
        ) {
    this.isSolid = isSolid;
  }

  @override
  void fillParent() {
    throw UnsupportedError(
      'Use the RectangleHitbox if you want to fill the parent',
    );
  }
}
