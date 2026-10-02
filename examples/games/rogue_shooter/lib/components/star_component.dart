import 'package:flame/components.dart';

class StarComponent({super.animation, super.position})
    extends SpriteAnimationComponent
    with HasGameRef {
  static const speed = 10;

  this : super(size: Vector2.all(20));

  @override
  void update(double dt) {
    super.update(dt);
    y += dt * speed;
    if (y >= gameRef.size.y) {
      removeFromParent();
    }
  }
}
