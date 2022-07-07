import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/src/geometry/ray2.dart';

/// [CollisionDetection] is the foundation of the collision detection system in
/// Flame.
///
/// If the [HasCollisionDetection] mixin is added to the game, [run] is
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
  /// `collisionType = CollisionType.inactive;` instead.
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
      if (tuple.a.collidingWith(tuple.b)) {
        handleCollisionEnd(tuple.a, tuple.b);
      }
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

  /// [raycast] gives back the first hitbox and intersection point which the
  /// ray hits. If there is no intersection null is returned.
  ///
  /// If [out] is provided that object will be modified and returned with the
  /// result.
  RaycastResult<T>? raycast(Ray2 ray, {RaycastResult<T>? out});

  /// [raytrace] gives back the all hitboxes and the intersection points which
  /// the ray hits.
  ///
  /// If [out] is provided the [RaycastResult]s in that list be modified and
  /// returned with the result. If there are less objects in [out] than the
  /// result requires, the missing [RaycastResult] objects will be created.
  Set<RaycastResult<T>> raytrace(Ray2 ray, {Iterable<RaycastResult<T>>? out});
}
