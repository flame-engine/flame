import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class BasicAnimations extends FlameGame with TapDetector {
  late Image creature;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    creature = await images.load('animations/creature.png');

    final animation = await loadSpriteAnimation(
      'animations/chopper.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    );

    final spriteSize = Vector2.all(100.0);
    final animationComponent2 = SpriteAnimationComponent(
      animation: animation,
      size: spriteSize,
    );
    animationComponent2.x = size.x / 2 - spriteSize.x;
    animationComponent2.y = spriteSize.y;

    final reversedAnimationComponent = SpriteAnimationComponent(
      animation: animation.reversed(),
      size: spriteSize,
    );
    reversedAnimationComponent.x = size.x / 2;
    reversedAnimationComponent.y = spriteSize.y;

    add(animationComponent2);
    add(reversedAnimationComponent);
  }

  void addAnimation(Vector2 position) {
    final size = Vector2(291, 178);

    final animationComponent = SpriteAnimationComponent.fromFrameData(
      creature,
      SpriteAnimationData.sequenced(
        amount: 18,
        amountPerRow: 10,
        textureSize: size,
        stepTime: 0.15,
        loop: false,
      ),
      size: size,
      removeOnFinish: true,
    );

    animationComponent.position = position - size / 2;
    add(animationComponent);
  }

  @override
  void onTapDown(TapDownInfo info) {
    addAnimation(info.eventPosition.game);
  }
}
