import 'package:flame/collisions.dart';
import 'package:meta/meta.dart';

/// The [Broadphase] class is used to make collision detection more efficient
/// by doing a rough estimation of which hitboxes that can collide before their
/// actual intersections are calculated.
///
/// Currently there are two implementations of [Broadphase]:
/// - [Sweep] is the simplest but slowest system, yet nice for small amounts of
///   hitboxes.
/// - [QuadTree] usually works faster, but requires additional setup and works
///   only with fixed-size maps. See [HasQuadTreeCollisionDetection] for
///   details.
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

  void addAll(Iterable<T> items) => items.forEach(add);

  /// Removes an item from the broadphase. Should be called in a
  /// [CollisionDetection] class while removing a hitbox from its collision
  /// detection system.
  void remove(T item);

  void removeAll(Iterable<T> items) => items.forEach(remove);

  /// Returns the potential hitbox collisions
  Set<CollisionProspect<T>> query();
}

/// A [CollisionProspect] is a tuple that is used to contain two potentially
/// colliding hitboxes.
@immutable
class CollisionProspect<T> {
  final T a;
  final T b;

  const CollisionProspect(this.a, this.b);

  @override
  bool operator ==(Object other) =>
      other is CollisionProspect &&
      ((other.a == a && other.b == b) || (other.a == b && other.b == a));

  @override
  int get hashCode => Object.hashAllUnordered([a, b]);
}
