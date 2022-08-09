import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

/// The default implementation of [CollisionDetection].
/// Checks whether any [ShapeHitbox]s in [items] collide with each other and
/// calls their callback methods accordingly.
///
/// By default the [Sweep] broadphase is used, this can be configured by
/// passing in another [Broadphase] to the constructor.
class StandardCollisionDetection extends CollisionDetection<ShapeHitbox> {
  StandardCollisionDetection({Broadphase<ShapeHitbox>? broadphase})
      : super(broadphase: broadphase ?? Sweep<ShapeHitbox>());

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

  static final _temporaryRaycastResult = RaycastResult<ShapeHitbox>(
    isActive: false,
  );

  @override
  RaycastResult<ShapeHitbox>? raycast(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    var finalResult = out?..reset();
    for (final item in items) {
      final currentResult =
          item.rayIntersection(ray, out: _temporaryRaycastResult);
      final possiblyFirstResult = !(finalResult?.isActive ?? false);
      if (currentResult != null &&
          (possiblyFirstResult ||
              currentResult.distance! < finalResult!.distance!)) {
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
    Vector2 origin,
    int amountOfRays, {
    double startAngle = 0,
    List<Ray2>? rays,
    List<RaycastResult<ShapeHitbox>>? out,
  }) {
    final angle = tau / amountOfRays;
    final results = <RaycastResult<ShapeHitbox>>[];
    for (var i = 0; i < amountOfRays; i++) {
      Ray2 ray;
      if (i < (rays?.length ?? 0)) {
        ray = rays![i];
      } else {
        ray = Ray2.zero();
        rays?.add(ray);
      }
      ray.origin.setFrom(origin);
      ray.direction
        ..setValues(1, 0)
        ..rotate(startAngle + angle * i);
      ray.updateInverses();

      RaycastResult<ShapeHitbox>? result;
      if (i < (out?.length ?? 0)) {
        result = out![i];
      } else {
        result = RaycastResult();
        out?.add(result);
      }
      result = raycast(ray, out: result);

      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }

  @override
  List<RaycastResult<ShapeHitbox>> raytrace(
    Ray2 ray, {
    double maxDepth = 100,
    List<RaycastResult<ShapeHitbox>>? out,
  }) {
    final result = out ?? <RaycastResult<ShapeHitbox>>[];
    var currentRay = ray;
    for (var i = 0; i < maxDepth; i++) {
      final hasResultObject = result.length > i;
      final currentResult =
          hasResultObject ? result[i] : RaycastResult<ShapeHitbox>();
      if (raycast(currentRay, out: currentResult) != null) {
        currentRay = currentResult.reflectionRay!;
        if (!hasResultObject) {
          result.add(currentResult);
        }
      } else {
        for (var j = i; j < result.length; j++) {
          result[j].reset();
        }
        break;
      }
    }
    return result;
  }
}
