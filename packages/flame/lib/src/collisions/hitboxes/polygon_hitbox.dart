// ignore_for_file: comment_references

import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';

/// A [Hitbox] in the shape of a polygon.
class PolygonHitbox extends PolygonComponent
    with ShapeHitbox, PolygonRayIntersection {
  PolygonHitbox(
    super.vertices, {
    super.position,
    super.angle,
    super.anchor,
    bool isSolid = false,
    CollisionType collisionType = CollisionType.active,
  }) {
    this.isSolid = isSolid;
    this.collisionType = collisionType;
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
    required super.parentSize,
    super.position,
    double super.angle = 0,
    super.anchor,
    bool isSolid = false,
    CollisionType collisionType = CollisionType.active,
  }) : super.relative(shrinkToBounds: true) {
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
      if (v.x < minX) {
        minX = v.x;
      }
      if (v.y < minY) {
        minY = v.y;
      }
      if (v.x > maxX) {
        maxX = v.x;
      }
      if (v.y > maxY) {
        maxY = v.y;
      }
    }
    // Add a small epsilon since points on the AABB edge are counted as outside.
    const epsilon = 0.000000000000001;
    aabb.min.setValues(minX - epsilon, minY - epsilon);
    aabb.max.setValues(maxX + epsilon, maxY + epsilon);
  }

  @override
  void fillParent() {
    throw UnsupportedError(
      'Use the RectangleHitbox if you want to fill the parent',
    );
  }
}
