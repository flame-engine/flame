import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';
import 'hitbox.dart';

mixin Collidable on Hitbox {
  /// Set whether [collidable] is active
  /// If [active collision] is set to true, collision with other [collisionable] will be actively checked in [collisiondetection]
  /// [collisable] whose [active collisional] is set to false will not actively check collisions with other [collisable],
  /// so as to prevent collision detection between stationary [collisable] and other stationary [collisable], so as to improve the performance of [collisiondetection]
  bool activeCollision = true;

  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {}
}

class ScreenCollidable extends PositionComponent with Hitbox, Collidable {
  ScreenCollidable() {
    addShape(HitboxRectangle());
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size.setFrom(gameSize);
  }
}
