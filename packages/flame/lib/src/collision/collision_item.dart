import '../../components.dart';

mixin CollisionItem<T> {
  Aabb2 get aabb;
  CollidableType get collidableType;

  void onCollision(Set<Vector2> intersectionPoints, T other) {}
  void onCollisionStart(Set<Vector2> intersectionPoints, T other) {}
  void onCollisionEnd(T other) {}
}
