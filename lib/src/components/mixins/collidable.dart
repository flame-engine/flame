import 'hitbox.dart';
import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';

mixin Collidable on Hitbox {
  bool hasScreenCollision = false;

  void collisionCallback(Set<Vector2> points, Collidable other) {}
}

class ScreenCollidable extends PositionComponent with Hitbox, Collidable {
  ScreenCollidable() {
    addShape(HitboxRectangle(Vector2.all(1.0)));
  }
  
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size.setFrom(gameSize);
  }
}
