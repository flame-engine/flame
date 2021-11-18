import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class Ember extends SpriteAnimationComponent with HasGameRef {
  Ember({Vector2? position, Vector2? size})
      : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      'animations/ember.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: Vector2.all(16),
        stepTime: 0.15,
      ),
    );
  }
}
