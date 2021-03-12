import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

class FlipSpriteGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    final image = await images.load('animations/chopper.png');

    final regular = buildAnimationComponent(image);
    regular.y = 100;
    add(regular);

    final flipX = buildAnimationComponent(image);
    flipX.y = 300;
    flipX.renderFlipX = true;
    add(flipX);

    final flipY = buildAnimationComponent(image);
    flipY.y = 500;
    flipY.renderFlipY = true;
    add(flipY);
  }

  SpriteAnimationComponent buildAnimationComponent(Image image) {
    final ac = SpriteAnimationComponent(
      animation: buildAnimation(image),
      size: Vector2.all(100),
    );
    ac.x = size.x / 2 - ac.x / 2;
    return ac;
  }

  SpriteAnimation buildAnimation(Image image) {
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    );
  }
}
