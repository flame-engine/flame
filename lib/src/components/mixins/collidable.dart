import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';
import 'hitbox.dart';

mixin Collidable on Hitbox {
  /// Set whether [Collidable] is active
  /// If [activeCollidable] is set to true, collision with other [Collidable] will be actively checked in [collisionDetection]
  /// [Collidable] whose [activeCollidable] is set to false will not actively check collisions with other [Collidable],
  /// so as to prevent collision detection between stationary [Collidable] and other stationary [Collidable], so as to improve the performance of [collisionDetection]
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
