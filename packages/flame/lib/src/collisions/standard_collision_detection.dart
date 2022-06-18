import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/src/geometry/ray2.dart';

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

  late final _temporaryRaycastResult = RaycastResult<ShapeHitbox>();

  @override
  RaycastResult<ShapeHitbox>? raycast(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    final broadphaseResult = broadphase.raycast(ray);
    if (broadphaseResult.isEmpty) {
      return null;
    }
    final raycastResult = (out?..reset()) ?? RaycastResult();
    var hasResult = false;
    for (final potential in broadphaseResult) {
      final result =
          potential.rayIntersection(ray, out: _temporaryRaycastResult);
      if (result != null && result.distance < raycastResult.distance) {
        hasResult = true;
        raycastResult.setFrom(result);
      }
    }
    return hasResult ? raycastResult : null;
  }

  @override
  Set<RaycastResult<ShapeHitbox>> raycastAll(
    Ray2 ray, {
    Iterable<RaycastResult<Hitbox<ShapeHitbox>>>? out,
  }) {
    // TODO: implement raycastAll
    throw UnimplementedError();
  }
}
