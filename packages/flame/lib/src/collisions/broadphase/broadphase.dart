import 'package:flame/collisions.dart';

/// The [Broadphase] class is used to make collision detection more efficient
/// by doing a rough estimation of which hitboxes that can collide before their
/// actual intersections are calculated.
///
/// Currently there are two implementations of [Broadphase]:
///
/// - [Sweep] is the simplest system. It simply short-circuits potential
///   collisions based on the horizontal (x) position of the components
///   in question. It is the default implementation when you use
///   `HasCollisionDetection`.
/// - [QuadTree] works faster in some cases. It requires additional setup
///   and works only with fixed-size maps. See [HasQuadTreeCollisionDetection]
///   for details.
///
/// Always experiment to see which approach works best for your game.
abstract class Broadphase<T extends Hitbox<T>> {
  Broadphase();

  /// This method can be used if there are things that needs to be prepared in
  /// each tick.
  void update() {}

  /// Returns a flat List of items regardless of what data structure is used to
  /// store collision information.
  List<T> get items;

  /// Adds an item to the broadphase. Should be called in a
  /// [CollisionDetection] class while adding a hitbox into its collision
  /// detection system.
  void add(T item);

  void addAll(Iterable<T> items) {
    for (final item in items) {
      add(item);
    }
  }

  /// Removes an item from the broadphase. Should be called in a
  /// [CollisionDetection] class while removing a hitbox from its collision
  /// detection system.
  void remove(T item);

  void removeAll(Iterable<T> items) {
    for (final item in items) {
      remove(item);
    }
  }

  /// Returns the potential hitbox collisions
  Iterable<CollisionProspect<T>> query();
}
