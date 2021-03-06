import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';
import 'hitbox.dart';

/// [CollisionType.active] collides with other [Collidable]s of type active or static
/// [CollisionType.static] collides with other [Collidable]s of type active
/// [CollisionType.inactive] will not collide with any other [Collidable]s
enum CollisionType {
  active,
  static,
  inactive,
}

mixin Collidable on Hitbox {
  CollisionType collisionType = CollisionType.active;

  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {}
}

class ScreenCollidable extends PositionComponent with Hitbox, Collidable {
  @override
  CollisionType collisionType = CollisionType.static;

  ScreenCollidable() {
    addShape(HitboxRectangle());
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size.setFrom(gameSize);
  }
}
