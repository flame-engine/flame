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
  /// Whether the ray starts inside the polygon is decided by the parity of the
  /// edges that it crosses, which works for concave polygons as well.
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    final vertices = globalVertices();
    var closestDistance = double.infinity;
    Vector2? closestFrom;
    Vector2? closestTo;
    var crossings = 0;
    final originX = ray.origin.x;
    final originY = ray.origin.y;
    final directionX = ray.direction.x;
    final directionY = ray.direction.y;
    // Float32List (used by Vector2) carries ~7 significant digits. After
    // reflecting, the stored origin can drift by up to |coord| * 2^-23.
    // Scale epsilon to the origin's magnitude so we skip self-intersections
    // without missing real hits.
    final epsilon = max(1.0, max(originX.abs(), originY.abs())) * 1e-4;
    // An edge crosses the line of the ray when its vertices are on opposite
    // sides of it, with a vertex on the line assigned to one side, so that a
    // ray through a vertex crosses once and a touch crosses twice or not at
    // all. The side of each vertex is computed once and shared by both of its
    // edges, which is what keeps a ray from slipping through between them.
    var from = vertices[vertices.length - 1];
    var fromSide =
        directionX * (from.y - originY) - directionY * (from.x - originX);
    for (var i = 0; i < vertices.length; i++) {
      final to = vertices[i];
      final toSide =
          directionX * (to.y - originY) - directionY * (to.x - originX);
      if ((fromSide > 0 && toSide <= 0) || (fromSide <= 0 && toSide > 0)) {
        final edgeX = to.x - from.x;
        final edgeY = to.y - from.y;
        final distance =
            (edgeX * (originY - from.y) - edgeY * (originX - from.x)) /
            (edgeY * directionX - edgeX * directionY);
        if (distance > epsilon) {
          crossings++;
          if (distance < closestDistance) {
            closestDistance = distance;
            closestFrom = from;
            closestTo = to;
          }
        }
      }
      from = to;
      fromSide = toSide;
    }
    if (closestFrom != null && closestTo != null) {
      final intersectionPoint = ray.point(
        closestDistance,
        out: out?.intersectionPoint,
      );
      // This is "from" to "to" since it is defined ccw in the canvas
      // coordinate system
      _temporaryNormal
        ..setFrom(closestFrom)
        ..sub(closestTo);
      _temporaryNormal
        ..setValues(_temporaryNormal.y, -_temporaryNormal.x)
        ..normalize();
      final isInsideHitbox = crossings.isOdd;
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
