import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';
import 'hitbox.dart';

/// [CollidableType.active] collides with other [Collidable]s of type active or static
/// [CollidableType.static] collides with other [Collidable]s of type active
/// [CollidableType.inactive] will not collide with any other [Collidable]s
enum CollidableType {
  active,
  static,
  inactive,
}

mixin Collidable on Hitbox {
  CollidableType collisionType = CollidableType.active;

  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {}
}

class ScreenCollidable extends PositionComponent with Hitbox, Collidable {
  @override
  CollidableType collisionType = CollidableType.static;

  ScreenCollidable() {
    addShape(HitboxRectangle());
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size.setFrom(gameSize);
  }
}
