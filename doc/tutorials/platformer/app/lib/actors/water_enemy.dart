import 'package:EmberQuest/main.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class WaterEnemy extends SpriteAnimationComponent
    with HasGameRef<EmberQuestGame> {
  WaterEnemy({
    required super.position,
  }) : super(size: Vector2.all(64));

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      await gameRef.images.load('water_enemy.png'),
      SpriteAnimationData.sequenced(
        amount: 2,
        textureSize: Vector2.all(16),
        stepTime: 0.70,
      ),
    );

    //debugMode = true; //Set to true to see the bounding boxes
    add(
      RectangleHitbox()..collisionType = CollisionType.active,
    );
    add(
      MoveEffect.by(
        Vector2(-300, 0),
        EffectController(
          duration: 3,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }
}
