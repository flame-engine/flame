import 'package:flame/collisions.dart';
import 'package:meta/meta.dart';

/// The [Broadphase] class is used to make collision detection more efficient
/// by doing a rough estimation of which hitboxes that can collide before their
/// actual intersections are calculated.
///
/// Currently there is only one implementation of [Broadphase] and that is
/// [Sweep].
abstract class Broadphase<T extends Hitbox<T>> {
  Broadphase();

  /// This method can be used if there are things that needs to be prepared in
  /// each tick.
  void update() {}

  /// Returns a flat List of items regardless of what data structure is used to
  /// store collision information
  List<T> get items;

  /// Add item to broadphase. Should be called in [CollisionDetection] class
  /// while adding a hitbox into collision detection system
  void add(T item);

  void addAll(Iterable<T> items) => items.forEach(add);

  /// Remove item from broadphase. Should be called in [CollisionDetection]
  /// class while removing a hitbox into collision detection system
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
  bool operator ==(Object o) =>
      o is CollisionProspect &&
      ((o.a == a && o.b == b) || (o.a == b && o.b == a));

  @override
  int get hashCode => Object.hashAllUnordered([a, b]);
}
