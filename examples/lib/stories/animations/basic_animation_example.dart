import 'dart:ui';

import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class BasicAnimationsExample extends FlameGame with TapDetector {
  static const description = '''
    Basic example of `SpriteAnimation`s use in Flame's `FlameGame`\n\n
    
    The snippet shows how an animation can be loaded and added to the game
    ```
    class MyGame extends FlameGame {
      @override
      Future<void> onLoad() async {
        final animation = await loadSpriteAnimation(
          'animations/chopper.png',
          SpriteAnimationData.sequenced(
            amount: 4,
            textureSize: Vector2.all(48),
            stepTime: 0.15,
          ),
        );
    
        final animationComponent = SpriteAnimationComponent(
          animation: animation,
          size: Vector2.all(100.0),
        );
    
        add(animationComponent);
      }
    }
    ```

    On this example, click or touch anywhere on the screen to dynamically add
    animations.
  ''';

  late Image creature;

  @override
  Future<void> onLoad() async {
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
    final animationComponent = SpriteAnimationComponent(
      animation: animation,
      size: spriteSize,
    );
    animationComponent.x = size.x / 2 - spriteSize.x;
    animationComponent.y = spriteSize.y;

    final reversedAnimationComponent = SpriteAnimationComponent(
      animation: animation.reversed(),
      size: spriteSize,
    );
    reversedAnimationComponent.x = size.x / 2;
    reversedAnimationComponent.y = spriteSize.y;

    add(animationComponent);
    add(reversedAnimationComponent);
    add(Ember()..position = size / 2);
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
