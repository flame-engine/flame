import 'package:flame/src/collisions/broadphase/broadphase.dart';
import 'package:flame/src/collisions/hitboxes/hitbox.dart';

class ProspectPool<T extends Hitbox<T>> {
  ProspectPool({this.incrementSize = 1000});

  /// How much the pool should increase in size every time it needs to be made
  /// larger.
  final int incrementSize;
  final _storage = <CollisionProspect<T>>[];
  int get length => _storage.length;

  /// The size of the pool will expand with [incrementSize] amount of
  /// [CollisionProspect]s that are initially populated with two [dummyItem]s.
  void expand(T dummyItem) {
    for (var i = 0; i < incrementSize; i++) {
      _storage.add(CollisionProspect<T>(dummyItem, dummyItem));
    }
  }

  CollisionProspect<T> operator [](int index) => _storage[index];
}
