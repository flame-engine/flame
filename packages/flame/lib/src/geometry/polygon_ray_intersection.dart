import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

/// Used to add the [rayIntersection] method to [RectangleHitbox] and
/// [PolygonHitbox], used by the raytracing and raycasting methods.
mixin PolygonRayIntersection<T extends ShapeHitbox> on PolygonComponent {
  late final _temporaryNormal = Vector2.zero();

  /// Returns whether the [RaycastResult] if the [ray] intersects the polygon.
  ///
  /// If [out] is defined that is used to populate with the result and then
  /// returned, to minimize the creation of new objects.
  ///
  /// When [useContainment] is `false` (default for backwards compatibility),
  /// the standard edge-crossing behavior is used; otherwise, the behavior
  /// is based on point containment, which is more expensive but should work
  /// on concave polygons as well.
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
    bool useContainment = false,
  }) {
    final vertices = globalVertices();
    var closestDistance = double.infinity;
    LineSegment? closestSegment;
    var crossings = 0;
    var isOverlappingPoint = false;
    // Float32List (used by Vector2) carries ~7 significant digits. After
    // reflecting, the stored origin can drift by up to |coord| * 2^-23.
    // Scale epsilon to the origin's magnitude so we skip self-intersections
    // without missing real hits.
    final epsilon =
        max(1.0, max(ray.origin.x.abs(), ray.origin.y.abs())) * 1e-4;
    for (var i = 0; i < vertices.length; i++) {
      final lineSegment = getEdge(i, vertices: vertices);
      final distance = ray.lineSegmentIntersection(lineSegment);
      if (distance != null && distance > epsilon) {
        if (!useContainment) {
          crossings++;
        }
        if (distance < closestDistance) {
          if (!useContainment) {
            isOverlappingPoint = false;
          }
          closestDistance = distance;
          closestSegment = lineSegment;
        } else if (!useContainment && distance == closestDistance) {
          isOverlappingPoint = true;
        }
      }
    }
    if (closestSegment != null) {
      final intersectionPoint = ray.point(
        closestDistance,
        out: out?.intersectionPoint,
      );
      // This is "from" to "to" since it is defined ccw in the canvas
      // coordinate system
      _temporaryNormal
        ..setFrom(closestSegment.from)
        ..sub(closestSegment.to);
      _temporaryNormal
        ..setValues(_temporaryNormal.y, -_temporaryNormal.x)
        ..normalize();
      final isInsideHitbox = useContainment
          ? containsPointInVertices(ray.origin, vertices)
          : crossings.isOdd || isOverlappingPoint;
      if (isInsideHitbox) {
        _temporaryNormal.invert();
      }
      final reflectionDirection =
          (out?.reflectionRay?.direction ?? Vector2.zero())
            ..setFrom(ray.direction)
            ..reflect(_temporaryNormal);
      // Reflect() can introduce sub-epsilon drift. Normalize to keep Ray2's
      // unit-length assertion satisfied.
      reflectionDirection.normalize();

      final reflectionRay =
          (out?.reflectionRay?..setWith(
            origin: intersectionPoint,
            direction: reflectionDirection,
          )) ??
          Ray2(origin: intersectionPoint, direction: reflectionDirection);
      return (out ?? RaycastResult<ShapeHitbox>())..setWith(
        hitbox: this as T,
        reflectionRay: reflectionRay,
        normal: _temporaryNormal,
        distance: closestDistance,
        isInsideHitbox: isInsideHitbox,
      );
    }
    out?.reset();
    return null;
  }
}
