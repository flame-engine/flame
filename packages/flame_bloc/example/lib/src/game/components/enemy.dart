import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flame_bloc_example/src/game/components/explosion.dart';
import 'package:flame_bloc_example/src/game/game.dart';

class EnemyComponent extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  static const enemySpeed = 50;

  bool destroyed = false;

  EnemyComponent(double x, double y)
      : super(position: Vector2(x, y), size: Vector2.all(25)) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      'enemy.png',
      SpriteAnimationData.sequenced(
        stepTime: 0.2,
        amount: 4,
        textureSize: Vector2.all(16),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    y += enemySpeed * dt;
    if (destroyed || y >= gameRef.size.y) {
      removeFromParent();
    }
  }

  void takeHit() {
    destroyed = true;

    gameRef.add(ExplosionComponent(x - 25, y - 25));
    gameRef.increaseScore();
  }
}
