import 'tuple.dart';

enum BroadphaseType { sweep }

abstract class Broadphase<T extends CollisionItem> {
  final List<T> items;
  Broadphase(this.items);

  Iterable<Potential<T>> query();
}
