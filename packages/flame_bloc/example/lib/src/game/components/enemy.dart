import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

import './explosion.dart';
import '../game.dart';

class EnemyComponent extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame>, HasHitboxes, Collidable {
  static const enemySpeed = 50;

  bool destroyed = false;

  EnemyComponent(double x, double y)
      : super(position: Vector2(x, y), size: Vector2.all(25)) {
    addHitbox(HitboxRectangle());
    collidableType = CollidableType.passive;
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
    collidableType = CollidableType.passive;
  }

  @override
  void update(double dt) {
    y += enemySpeed * dt;
    shouldRemove = destroyed || y >= gameRef.size.y;
  }

  void takeHit() {
    destroyed = true;

    gameRef.add(ExplosionComponent(x - 25, y - 25));
    gameRef.increaseScore();
  }
}
