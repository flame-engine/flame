import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';
import 'hitbox.dart';

/// [CollidableType.active] collides with other [Collidable]s of type active or static
/// [CollidableType.passive] collides with other [Collidable]s of type active
/// [CollidableType.inactive] will not collide with any other [Collidable]s
enum CollidableType {
  active,
  passive,
  inactive,
}

mixin Collidable on Hitbox {
  CollidableType collidableType = CollidableType.active;

  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {}
}

class ScreenCollidable extends PositionComponent with Hitbox, Collidable {
  @override
  CollidableType collidableType = CollidableType.passive;

  ScreenCollidable() {
    addShape(HitboxRectangle());
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
