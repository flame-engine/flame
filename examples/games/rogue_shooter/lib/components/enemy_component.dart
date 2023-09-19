import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:rogue_shooter/components/explosion_component.dart';
import 'package:rogue_shooter/rogue_shooter_game.dart';

class EnemyComponent extends SpriteAnimationComponent
    with HasGameReference<RogueShooterGame>, CollisionCallbacks {
  static const speed = 150;
  static final Vector2 initialSize = Vector2.all(25);

  EnemyComponent({required super.position})
      : super(size: initialSize, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    animation = await game.loadSpriteAnimation(
      'rogue_shooter/enemy.png',
      SpriteAnimationData.sequenced(
        stepTime: 0.2,
        amount: 4,
        textureSize: Vector2.all(16),
      ),
    );
    add(CircleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    y += speed * dt;
    if (y >= game.size.y) {
      removeFromParent();
    }
  }

  void takeHit() {
    removeFromParent();

    game.add(ExplosionComponent(position: position));
    game.increaseScore();
  }
}
