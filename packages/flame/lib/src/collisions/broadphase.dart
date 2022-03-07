import 'package:meta/meta.dart';

import '../../collisions.dart';

/// The [Broadphase] class is used to make collision detection more efficient
/// by doing a rough estimation of which hitboxes that can collide before their
/// actual intersections are calculated.
///
/// Currently there is only one implementation of [Broadphase] and that is
/// [Sweep].
abstract class Broadphase<T extends Hitbox<T>> {
  final List<T> items;

  Broadphase({List<T>? items}) : items = items ?? [];

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
  bool operator ==(Object o) => o is CollisionProspect && o.a == a && o.b == b;

  @override
  int get hashCode => Object.hash(a.hashCode, b.hashCode);
}
