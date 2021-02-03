import 'hitbox.dart';
import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';

mixin Collidable on Hitbox {
  bool hasScreenCollision = false;

  void collisionCallback(Set<Vector2> points, Collidable other) {}
}

class CollidableScreen extends PositionComponent with Hitbox, Collidable {
  CollidableScreen(Vector2 screenSize) {
    position = Vector2.zero();
    size = screenSize;
    addShape(HitboxRectangle(Vector2.all(1.0)));
  }
}
