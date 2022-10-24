import 'package:collision_detection_performance/game.dart';
import 'package:flame/components.dart';

class StarComponent extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  static const speed = 10;

  StarComponent({super.animation, super.position})
      : super(size: Vector2.all(20));

  @override
  void update(double dt) {
    super.update(dt);
    y += dt * speed;
    if (y >= gameRef.size.y) {
      removeFromParent();
    }
  }
}
