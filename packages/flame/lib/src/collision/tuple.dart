import 'package:meta/meta.dart';

import '../../components.dart';

abstract class CollisionItem<T> {
  Aabb2 get aabb;
  CollidableType get collidableType;

  void onCollision(Set<Vector2> intersectionPoints, T other) {}
  void onCollisionStart(Set<Vector2> intersectionPoints, T other) {}
  void onCollisionEnd(T other) {}
}

@immutable
class Potential<T> {
  final T a;
  final T b;

  const Potential(this.a, this.b);
}
