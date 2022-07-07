import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

/// A [Hitbox] in the shape of a polygon.
mixin PolygonRayIntersection<T extends ShapeHitbox> on PolygonComponent {
  late final _temporaryNormal = Vector2.zero();

  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    final vertices = globalVertices();
    var closestDistance = double.infinity;
    LineSegment? closestSegment;
    var crossings = 0;
    for (var i = 0; i < vertices.length; i++) {
      final lineSegment = getEdge(i, vertices: vertices);
      final distance = ray.lineSegmentIntersection(lineSegment);
      if (distance != null) {
        crossings++;
        if (distance < closestDistance) {
          closestDistance = distance;
          closestSegment = lineSegment;
        }
      }
    }
    if (crossings > 0) {
      out?.isActive = true;
      final intersectionPoint = ray.point(closestDistance, out: out?.point);
      // This is from - to since it is defined ccw in the canvas
      // coordinate system
      _temporaryNormal
        ..setFrom(closestSegment!.from)
        ..sub(closestSegment.to);
      // TODO(spydon): The normal needs to be inverted if it is only one crossing
      _temporaryNormal
        ..setValues(_temporaryNormal.y, -_temporaryNormal.x)
        ..normalize();
      final reflectionDirection =
          (out?.reflectionRay?.direction ?? Vector2.zero())
            ..setFrom(ray.direction)
            ..reflect(_temporaryNormal);

      final reflectionRay = (out?.reflectionRay
            ?..setWith(
              origin: intersectionPoint,
              direction: reflectionDirection,
            )) ??
          Ray2(intersectionPoint, reflectionDirection);
      return (out ?? RaycastResult<ShapeHitbox>())
        ..setWith(
          hitbox: this as T,
          reflectionRay: reflectionRay,
          normal: _temporaryNormal,
          distance: closestDistance,
        );
    }
    out?.isActive = false;
    return null;
  }
}
