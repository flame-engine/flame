import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

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
    broadphase.update();
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

  /// Returns the first hitbox that the given [ray] hits and the associated
  /// intersection information; or null if the ray doesn't hit any hitbox.
  ///
  /// [ignoreHitboxes] can be used if you want to ignore certain hitboxes, i.e.
  /// the rays will go straight through them. For example the hitbox of the
  /// component that you might be casting the rays from.
  ///
  /// If [out] is provided that object will be modified and returned with the
  /// result.
  RaycastResult<T>? raycast(
    Ray2 ray, {
    List<T>? ignoreHitboxes,
    RaycastResult<T>? out,
  });

  /// Casts rays uniformly between [startAngle] to [startAngle]+[sweepAngle]
  /// from the given [origin] and returns all hitboxes and intersection points
  /// the rays hit.
  /// [numberOfRays] is the number of rays that should be casted.
  ///
  /// If the [rays] argument is provided its [Ray2]s are populated with the rays
  /// needed to perform the operation.
  /// If there are less objects in [rays] than the operation requires, the
  /// missing [Ray2] objects will be created and added to [rays].
  ///
  /// [ignoreHitboxes] can be used if you want to ignore certain hitboxes, i.e.
  /// the rays will go straight through them. For example the hitbox of the
  /// component that you might be casting the rays from.
  ///
  /// If [out] is provided the [RaycastResult]s in that list be modified and
  /// returned with the result. If there are less objects in [out] than the
  /// result requires, the missing [RaycastResult] objects will be created.
  List<RaycastResult<T>> raycastAll(
    Vector2 origin, {
    required int numberOfRays,
    double startAngle = 0,
    double sweepAngle = tau,
    List<Ray2>? rays,
    List<T>? ignoreHitboxes,
    List<RaycastResult<T>>? out,
  });

  /// Follows the ray and its reflections until [maxDepth] is reached and then
  /// returns all hitboxes, intersection points, normals and reflection rays
  /// (bundled in a list of [RaycastResult]s) from where the ray hits.
  ///
  /// [maxDepth] is how many times the ray should collide before returning a
  /// result, defaults to 10.
  ///
  /// [ignoreHitboxes] can be used if you want to ignore certain hitboxes, i.e.
  /// the rays will go straight through them. For example the hitbox of the
  /// component that you might be casting the rays from.
  ///
  /// If [out] is provided the [RaycastResult]s in that list be modified and
  /// returned with the result. If there are less objects in [out] than the
  /// result requires, the missing [RaycastResult] objects will be created.
  Iterable<RaycastResult<T>> raytrace(
    Ray2 ray, {
    int maxDepth = 10,
    List<T>? ignoreHitboxes,
    List<RaycastResult<T>>? out,
  });
}
