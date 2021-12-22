import 'tuple.dart';

enum BroadphaseType { sweep }

abstract class Broadphase<T> {
  final List<CollisionItem<T>> items;
  Broadphase(this.items);

  Iterable<Potential<T>> query();
}
