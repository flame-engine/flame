import '../../collisions.dart';
import '../../components.dart';

/// [CollisionDetection] is the foundation of the collision detection system in
/// Flame. If the [HasCollisionDetection] mixin is added to the game, [run] is
/// called every tick to check for collisions
abstract class CollisionDetection<T extends Hitbox<T>> {
  final Broadphase<T> broadphase;
  List<T> get items => broadphase.items;
  final Set<CollisionProspect<T>> _lastPotentials = {};

  CollisionDetection({required this.broadphase});

  void add(T item) => items.add(item);
  void addAll(Iterable<T> items) => items.forEach(add);

  /// Removes the [item] from the collision detection, if you just want
  /// to temporarily inactivate it you can set
  /// `collidableType = CollidableType.inactive;` instead.
  void remove(T item) => items.remove(item);

  /// Removes all [items] from the collision detection, see [remove].
  void removeAll(Iterable<T> items) => items.forEach(remove);

  /// Run collision detection for the current state of [items].
  void run() {
    final potentials = broadphase.query();
    potentials.forEach((tuple) {
      final itemA = tuple.a;
      final itemB = tuple.b;

      if (itemA.possiblyIntersects(itemB)) {
        final intersectionPoints = intersections(itemA, itemB);
        if (intersectionPoints.isNotEmpty) {
          if (!itemA.collidingWith(itemB)) {
            handleCollisionStart(intersectionPoints, itemA, itemB);
          }
          handleCollision(intersectionPoints, itemA, itemB);
        } else if (itemA.collidingWith(itemB)) {
          handleCollisionEnd(itemA, itemB);
        }
      } else if (itemA.collidingWith(itemB)) {
        handleCollisionEnd(itemA, itemB);
      }
    });

    // Handles callbacks for an ended collision that the broadphase didn't
    // reports as a potential collision anymore.
    _lastPotentials.difference(potentials).forEach((tuple) {
      handleCollisionEnd(tuple.a, tuple.b);
    });
    _lastPotentials
      ..clear()
      ..addAll(potentials);
  }

  /// Check what the intersection points of two items are,
  /// returns an empty list if there are no intersections.
  Set<Vector2> intersections(T itemA, T itemB);
  void handleCollisionStart(Set<Vector2> intersectionPoints, T itemA, T itemB);
  void handleCollision(Set<Vector2> intersectionPoints, T itemA, T itemB);
  void handleCollisionEnd(T itemA, T itemB);
}

/// The default implementation of [CollisionDetection].
/// Checks whether any [HitboxShape]s in [items] collide with each other and
/// calls their callback methods accordingly.
///
/// By default the [Sweep] broadphase is used, this can be configured by
/// passing in another [Broadphase] to the constructor.
class StandardCollisionDetection extends CollisionDetection<HitboxShape> {
  StandardCollisionDetection({Broadphase<HitboxShape>? broadphase})
      : super(broadphase: broadphase ?? Sweep<HitboxShape>());

  /// Check what the intersection points of two collidables are,
  /// returns an empty list if there are no intersections.
  @override
  Set<Vector2> intersections(
    HitboxShape hitboxA,
    HitboxShape hitboxB,
  ) {
    return hitboxA.intersections(hitboxB);
  }

  /// Calls the two colliding hitboxes when they first starts to collide.
  /// They are called with the [intersectionPoints] and instances of each other,
  /// so that they can determine what hitbox (and what
  /// [HitboxShape.hitboxParent] that they have collided with.
  @override
  void handleCollisionStart(
    Set<Vector2> intersectionPoints,
    HitboxShape hitboxA,
    HitboxShape hitboxB,
  ) {
    hitboxA.onCollisionStart(intersectionPoints, hitboxB);
    hitboxB.onCollisionStart(intersectionPoints, hitboxA);
  }

  /// Calls the two colliding hitboxes every tick when they are colliding.
  /// They are called with the [intersectionPoints] and instances of each other,
  /// so that they can determine what hitbox (and what
  /// [HitboxShape.hitboxParent] that they have collided with.
  @override
  void handleCollision(
    Set<Vector2> intersectionPoints,
    HitboxShape hitboxA,
    HitboxShape hitboxB,
  ) {
    hitboxA.onCollision(intersectionPoints, hitboxB);
    hitboxB.onCollision(intersectionPoints, hitboxA);
  }

  /// Calls the two colliding hitboxes once when two hitboxes have stopped
  /// colliding.
  /// They are called with instances of each other, so that they can determine
  /// what hitbox (and what [HitboxShape.hitboxParent] that they have stopped
  /// colliding with.
  @override
  void handleCollisionEnd(HitboxShape hitboxA, HitboxShape hitboxB) {
    hitboxA.onCollisionEnd(hitboxB);
    hitboxB.onCollisionEnd(hitboxA);
  }
}
