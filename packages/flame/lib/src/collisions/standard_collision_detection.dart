import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

/// The default implementation of [CollisionDetection].
/// Checks whether any [ShapeHitbox]s in [items] collide with each other and
/// calls their callback methods accordingly.
///
/// By default the [Sweep] broadphase is used, this can be configured by
/// passing in another [Broadphase] to the constructor.
class StandardCollisionDetection<B extends Broadphase<ShapeHitbox>>
    extends CollisionDetection<ShapeHitbox, B> {
  StandardCollisionDetection({B? broadphase})
    : super(broadphase: broadphase ?? Sweep<ShapeHitbox>() as B);

  /// Check what the intersection points of two collidables are,
  /// returns an empty list if there are no intersections.
  @override
  Set<Vector2> intersections(
    ShapeHitbox hitboxA,
    ShapeHitbox hitboxB,
  ) {
    return hitboxA.intersections(hitboxB);
  }

  /// Calls the two colliding hitboxes when they first starts to collide.
  /// They are called with the [intersectionPoints] and instances of each other,
  /// so that they can determine what hitbox (and what
  /// [ShapeHitbox.hitboxParent] that they have collided with.
  @override
  void handleCollisionStart(
    Set<Vector2> intersectionPoints,
    ShapeHitbox hitboxA,
    ShapeHitbox hitboxB,
  ) {
    hitboxA.onCollisionStart(intersectionPoints, hitboxB);
    hitboxB.onCollisionStart(intersectionPoints, hitboxA);
  }

  /// Calls the two colliding hitboxes every tick when they are colliding.
  /// They are called with the [intersectionPoints] and instances of each other,
  /// so that they can determine what hitbox (and what
  /// [ShapeHitbox.hitboxParent] that they have collided with.
  @override
  void handleCollision(
    Set<Vector2> intersectionPoints,
    ShapeHitbox hitboxA,
    ShapeHitbox hitboxB,
  ) {
    hitboxA.onCollision(intersectionPoints, hitboxB);
    hitboxB.onCollision(intersectionPoints, hitboxA);
  }

  /// Calls the two colliding hitboxes once when two hitboxes have stopped
  /// colliding.
  /// They are called with instances of each other, so that they can determine
  /// what hitbox (and what [ShapeHitbox.hitboxParent] that they have stopped
  /// colliding with.
  @override
  void handleCollisionEnd(ShapeHitbox hitboxA, ShapeHitbox hitboxB) {
    hitboxA.onCollisionEnd(hitboxB);
    hitboxB.onCollisionEnd(hitboxA);
  }

  static final _temporaryRaycastResult = RaycastResult<ShapeHitbox>();

  static final _temporaryRayAabb = Aabb2();

  @override
  RaycastResult<ShapeHitbox>? raycast(
    Ray2 ray, {
    double? maxDistance,
    bool Function(ShapeHitbox candidate)? hitboxFilter,
    List<ShapeHitbox>? ignoreHitboxes,
    RaycastResult<ShapeHitbox>? out,
  }) {
    var finalResult = out?..reset();
    _updateRayAabb(ray, maxDistance);
    for (final item in items) {
      if (ignoreHitboxes?.contains(item) ?? false) {
        continue;
      }
      if (hitboxFilter != null) {
        if (!hitboxFilter(item)) {
          continue;
        }
      }
      if (!item.aabb.intersectsWithAabb2(_temporaryRayAabb)) {
        continue;
      }
      final currentResult = item.rayIntersection(
        ray,
        out: _temporaryRaycastResult,
      );
      final possiblyFirstResult = !(finalResult?.isActive ?? false);
      if (currentResult != null &&
          (possiblyFirstResult ||
              currentResult.distance! < finalResult!.distance!) &&
          currentResult.distance! <= (maxDistance ?? double.infinity)) {
        if (finalResult == null) {
          finalResult = currentResult.clone();
        } else {
          finalResult.setFrom(currentResult);
        }
      }
    }
    return (finalResult?.isActive ?? false) ? finalResult : null;
  }

  @override
  List<RaycastResult<ShapeHitbox>> raycastAll(
    Vector2 origin, {
    required int numberOfRays,
    double startAngle = 0,
    double sweepAngle = tau,
    double? maxDistance,
    List<Ray2>? rays,
    bool Function(ShapeHitbox candidate)? hitboxFilter,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  }) {
    final isFullCircle = (sweepAngle % tau).abs() < 0.0001;
    final angle = sweepAngle / (numberOfRays + (isFullCircle ? 0 : -1));
    final results = <RaycastResult<ShapeHitbox>>[];
    final direction = Vector2(1, 0);
    for (var i = 0; i < numberOfRays; i++) {
      Ray2 ray;
      if (i < (rays?.length ?? 0)) {
        ray = rays![i];
      } else {
        ray = Ray2.zero();
        rays?.add(ray);
      }
      ray.origin.setFrom(origin);
      direction
        ..setValues(0, -1)
        ..rotate(startAngle - angle * i);
      ray.direction = direction;

      RaycastResult<ShapeHitbox>? result;
      if (i < (out?.length ?? 0)) {
        result = out![i];
      } else {
        result = RaycastResult();
        out?.add(result);
      }
      result = raycast(
        ray,
        maxDistance: maxDistance,
        hitboxFilter: hitboxFilter,
        ignoreHitboxes: ignoreHitboxes,
        out: result,
      );

      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }

  @override
  Iterable<RaycastResult<ShapeHitbox>> raytrace(
    Ray2 ray, {
    int maxDepth = 10,
    bool Function(ShapeHitbox candidate)? hitboxFilter,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  }) sync* {
    if (out != null) {
      for (final result in out) {
        result.reset();
      }
    }
    var currentRay = ray;
    for (var i = 0; i < maxDepth; i++) {
      final hasResultObject = (out?.length ?? 0) > i;
      final storeResult = hasResultObject
          ? out![i]
          : RaycastResult<ShapeHitbox>();
      final currentResult = raycast(
        currentRay,
        hitboxFilter: hitboxFilter,
        ignoreHitboxes: ignoreHitboxes,
        out: storeResult,
      );
      if (currentResult != null) {
        currentRay = storeResult.reflectionRay!;
        if (!hasResultObject && out != null) {
          out.add(storeResult);
        }
        yield storeResult;
      } else {
        break;
      }
    }
  }

  /// Computes an axis-aligned bounding box for a [ray].
  ///
  /// When [maxDistance] is provided, this will be the bounding box around
  /// the origin of the ray and its ending point. When [maxDistance]
  /// is `null`, the bounding box will encompass the whole quadrant
  /// of space, from the ray's origin to infinity.
  void _updateRayAabb(Ray2 ray, double? maxDistance) {
    final x1 = ray.origin.x;
    final y1 = ray.origin.y;
    double x2;
    double y2;

    if (maxDistance != null) {
      x2 = ray.origin.x + ray.direction.x * maxDistance;
      y2 = ray.origin.y + ray.direction.y * maxDistance;
    } else {
      x2 = ray.direction.x > 0 ? double.infinity : double.negativeInfinity;
      y2 = ray.direction.y > 0 ? double.infinity : double.negativeInfinity;
    }

    _temporaryRayAabb
      ..min.setValues(math.min(x1, x2), math.min(y1, y2))
      ..max.setValues(math.max(x1, x2), math.max(y1, y2));
  }
}
