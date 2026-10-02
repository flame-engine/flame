import 'package:flame/components.dart';

import 'package:flame_bloc_example/src/game/game.dart';

class ExplosionComponent(double x, double y)
    extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  this
    : super(
        position: Vector2(x, y),
        size: Vector2.all(50),
        removeOnFinish: true,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      'assets/images/explosion.png',
      SpriteAnimationData.sequenced(
        stepTime: 0.1,
        amount: 6,
        loop: false,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
