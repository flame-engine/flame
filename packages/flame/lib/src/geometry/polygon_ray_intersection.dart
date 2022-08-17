import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

/// Used to add the [rayIntersection] method to [RectangleHitbox] and
/// [PolygonHitbox], used by the raytracing and raycasting methods.
mixin PolygonRayIntersection<T extends ShapeHitbox> on PolygonComponent {
  /// Returns whether the [RaycastResult] if the [ray] intersects the polygon.
  ///
  /// If [out] is defined that is used to populate with the result and then
  /// returned, to minimize the creation of new objects.
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    final vertices = globalVertices();
    var closestDistance = double.infinity;
    LineSegment? closestSegment;
    var crossings = 0;
    var isOverlappingPoint = false;
    for (var i = 0; i < vertices.length; i++) {
      final lineSegment = getEdge(i, vertices: vertices);
      final distance = ray.lineSegmentIntersection(lineSegment);
      // Using a small value above 0 just because of rounding errors later that
      // might cause a ray to go in the wrong direction.
      if (distance != null && distance > 0.0000000001) {
        crossings++;
        if (distance < closestDistance) {
          isOverlappingPoint = false;
          closestDistance = distance;
          closestSegment = lineSegment;
        } else if (distance == closestDistance) {
          isOverlappingPoint = true;
        }
      }
    }

    if (crossings > 0) {
      Vector2 intersectionPointFunction() =>
          ray.point(closestDistance, out: out?.rawIntersectionPoint);

      final result = (out ?? RaycastResult<ShapeHitbox>())
        ..setWith(
          hitbox: this as T,
          isInsideHitbox: crossings == 1 || isOverlappingPoint,
          originatingRay: ray,
          distanceFunction: () => closestDistance,
          intersectionPointFunction: intersectionPointFunction,
        );
      result.setWith(
        normalFunction: () => _rayNormal(
          closestSegment: closestSegment!,
          result: result,
        ),
      );
      result.setWith(
        reflectionRayFunction: () => _rayReflection(result: result),
      );
      return result;
    }
    out?.reset();
    return null;
  }

  /// This method is used to pass to the [RaycastResult] to lazily compute the
  /// normal.
  Vector2 _rayNormal({
    required LineSegment closestSegment,
    required RaycastResult result,
  }) {
    final normal = result.rawNormal ?? Vector2.zero();
    // This is "from" to "to" since it is defined ccw in the canvas
    // coordinate system
    normal
      ..setFrom(closestSegment.from)
      ..sub(closestSegment.to);
    normal
      ..setValues(normal.y, -normal.x)
      ..normalize();
    return result.isInsideHitbox ? (normal..invert()) : normal;
  }

  /// This method is used to pass to the [RaycastResult] to lazily compute the
  /// reflection.
  Ray2 _rayReflection({required RaycastResult result}) {
    final reflection = result.rawReflectionRay ?? Ray2.zero();
    final reflectionDirection = reflection.direction
      ..setFrom(result.originatingRay!.direction)
      ..reflect(result.normal!);

    return reflection
      ..setWith(
        origin: result.intersectionPoint!,
        direction: reflectionDirection,
      );
  }
}
