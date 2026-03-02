// ignore_for_file: comment_references

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/polygon_ray_intersection.dart';
import 'package:meta/meta.dart';

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
    bool isSolid = false,
    CollisionType collisionType = CollisionType.active,
  }) : shouldFillParent = size == null && position == null {
    this.isSolid = isSolid;
    this.collisionType = collisionType;
  }

  /// With this constructor you define the [RectangleHitbox] in relation to
  /// the [parentSize]. For example having [relation] as of (0.8, 0.5) would
  /// create a rectangle that fills 80% of the width and 50% of the height of
  /// [parentSize].
  RectangleHitbox.relative(
    super.relation, {
    required super.parentSize,
    super.position,
    super.angle,
    super.anchor,
    bool isSolid = false,
    CollisionType collisionType = CollisionType.active,
  }) : shouldFillParent = false,
       super.relative(
         shrinkToBounds: true,
       ) {
    this.isSolid = isSolid;
    this.collisionType = collisionType;
  }

  @override
  @protected
  void computeAabb(Aabb2 aabb) {
    final vertices = globalVertices();
    if (vertices.isEmpty) {
      super.computeAabb(aabb);
      return;
    }
    var minX = vertices[0].x;
    var minY = vertices[0].y;
    var maxX = vertices[0].x;
    var maxY = vertices[0].y;
    for (var i = 1; i < vertices.length; i++) {
      final v = vertices[i];
      if (v.x < minX) minX = v.x;
      if (v.y < minY) minY = v.y;
      if (v.x > maxX) maxX = v.x;
      if (v.y > maxY) maxY = v.y;
    }
    // Add a small epsilon since points on the AABB edge are counted as outside.
    const epsilon = 0.000000000000001;
    aabb.min.setValues(minX - epsilon, minY - epsilon);
    aabb.max.setValues(maxX + epsilon, maxY + epsilon);
  }

  @override
  void fillParent() {
    refreshVertices(
      newVertices: RectangleComponent.sizeToVertices(size, anchor),
    );
  }
}
