// ignore_for_file: comment_references

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/src/geometry/polygon_ray_intersection.dart';

/// A [Hitbox] in the shape of a rectangle (a simplified polygon).
class RectangleHitbox extends RectangleComponent
    with ShapeHitbox, PolygonRayIntersection<RectangleHitbox> {
  @override
  final bool shouldFillParent;

  RectangleHitbox({
    super.position,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
  }) : shouldFillParent = size == null && position == null;

  /// With this constructor you define the [RectangleHitbox] in relation to
  /// the [parentSize]. For example having [relation] as of (0.8, 0.5) would
  /// create a rectangle that fills 80% of the width and 50% of the height of
  /// [parentSize].
  RectangleHitbox.relative(
    super.relation, {
    super.position,
    required super.parentSize,
    super.angle,
    super.anchor,
  })  : shouldFillParent = false,
        super.relative(
          shrinkToBounds: true,
        );

  @override
  void fillParent() {
    refreshVertices(
      newVertices: RectangleComponent.sizeToVertices(size, anchor),
    );
  }
}
