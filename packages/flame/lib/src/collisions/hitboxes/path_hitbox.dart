import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';

/// A [Hitbox] in the shape of all the closed contours of a [Path].
///
/// The hitbox is a single hitbox, so it collides, contains points and is hit
/// by rays as a whole, whichever of its polygons is involved. See
/// [PathComponent] for how the polygons are made from the path.
class PathHitbox extends PathComponent with ShapeHitbox {
  /// With this constructor you create a [PathHitbox] from all the closed
  /// contours of the [path].
  ///
  /// See [PathComponent.new] for the [sampling], [tolerance] and [filter]
  /// parameters. Fewer vertices make the collision detection cheaper, so use
  /// the highest sampling that still follows the path closely enough.
  PathHitbox({
    required super.path,
    super.sampling,
    super.tolerance,
    super.filter,
    super.position,
    super.angle,
    super.anchor,
    super.isSolid,
    CollisionType collisionType = CollisionType.active,
  }) {
    this.collisionType = collisionType;
  }

  late final _temporaryNormal = Vector2.zero();
  late final _temporaryResult = RaycastResult<ShapeHitbox>();
  late final _closestResult = RaycastResult<ShapeHitbox>();

  /// Renders the polygons of the hitbox, since those are what collides.
  @override
  void render(Canvas canvas) {
    if (renderShape) {
      if (hasPaintLayers) {
        for (final paint in paintLayers) {
          canvas.drawPath(polygonsPath, paint);
        }
      } else {
        canvas.drawPath(polygonsPath, paint);
      }
    }
  }

  /// Returns information about how the ray intersects the closest of the
  /// polygons.
  ///
  /// If you are only interested in the intersection point use
  /// [RaycastResult.intersectionPoint] of the result.
  @override
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    var closestDistance = double.infinity;
    for (final vertices in globalPolygons()) {
      final result = PolygonRayIntersection.intersectPolygon(
        ray,
        vertices,
        hitbox: this,
        normal: _temporaryNormal,
        out: _temporaryResult,
      );
      final distance = result?.distance;
      if (distance != null && distance < closestDistance) {
        closestDistance = distance;
        _closestResult.setFrom(result!);
      }
    }
    if (closestDistance.isInfinite) {
      out?.reset();
      return null;
    }
    return (out ?? RaycastResult<ShapeHitbox>())..setFrom(_closestResult);
  }

  @override
  void fillParent() {
    throw UnsupportedError(
      'Use the RectangleHitbox if you want to fill the parent',
    );
  }

  /// Computes the [aabb] from the vertices of all the polygons.
  @override
  @protected
  void computeAabb(Aabb2 aabb) {
    final polygons = globalPolygons();
    if (polygons.isEmpty) {
      super.computeAabb(aabb);
      return;
    }
    final first = polygons.first.first;
    var minX = first.x;
    var minY = first.y;
    var maxX = first.x;
    var maxY = first.y;
    for (final vertices in polygons) {
      for (final v in vertices) {
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
    }
    // Add a small epsilon since points on the AABB edge are counted as outside.
    const epsilon = 0.000000000000001;
    aabb.min.setValues(minX - epsilon, minY - epsilon);
    aabb.max.setValues(maxX + epsilon, maxY + epsilon);
  }
}
