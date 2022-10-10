import 'package:EmberQuest/main.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class EmberPlayer extends SpriteAnimationComponent
    with HasGameRef<EmberQuestGame> {
  EmberPlayer({
    required super.position,
  }) : super(size: Vector2.all(64));

  Vector2 velocity = Vector2(0, 0);

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      await gameRef.images.load('ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );

    //debugMode = true; //Set to true to see the bounding boxes
    add(
      CircleHitbox()..collisionType = CollisionType.active,
    );
  }

  @override
  void update(double dt) {
    position += velocity * dt;
    super.update(dt);
  }
}
