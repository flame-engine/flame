import 'package:ember_quest/ember_quest.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class WaterEnemy extends SpriteAnimationComponent
    with HasGameRef<EmberQuestGame> {
  late Vector2 _gridPosition;
  late double _xPositionOffset;
  WaterEnemy({
    required Vector2 gridPosition,
    required double xPositionOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft) {
    _gridPosition = gridPosition;
    _xPositionOffset = xPositionOffset;
  }

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache('water_enemy.png'),
      SpriteAnimationData.sequenced(
        amount: 2,
        textureSize: Vector2.all(16),
        stepTime: 0.70,
      ),
    );
    position = Vector2((_gridPosition.x * size.x) + _xPositionOffset,
        gameRef.size.y - (_gridPosition.y * size.y));
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    add(
      MoveEffect.by(
        Vector2(-2 * size.x, 0),
        EffectController(
          duration: 3,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    Vector2 velocity = Vector2(gameRef.objectSpeed, 0);
    position += velocity * dt;
    if (position.x < -size.x || gameRef.health <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }
}
