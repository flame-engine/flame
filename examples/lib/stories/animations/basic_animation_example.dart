import 'dart:ui';

import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class BasicAnimationsExample extends FlameGame {
  static const description = '''
    Basic example of how to use `SpriteAnimation`s in Flame's.

    In this example, click or touch anywhere on the screen to dynamically add
    animations.
  ''';

  BasicAnimationsExample() : super(world: BasicAnimationsWorld());
}

class BasicAnimationsWorld extends World with TapCallbacks, HasGameReference {
  late Image creature;

  @override
  Future<void> onLoad() async {
    creature = await game.images.load('animations/creature.png');

    final animation = await game.loadSpriteAnimation(
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
      position: Vector2(-spriteSize.x, 0),
      size: spriteSize,
      anchor: Anchor.center,
    );

    final reversedAnimationComponent = SpriteAnimationComponent(
      animation: animation.reversed(),
      position: Vector2(spriteSize.x, 0),
      size: spriteSize,
      anchor: Anchor.center,
    );

    add(animationComponent);
    add(reversedAnimationComponent);
    add(Ember());
  }

  @override
  void onTapDown(TapDownEvent event) {
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
      position: event.localPosition,
      anchor: Anchor.center,
      size: size,
      removeOnFinish: true,
    );

    add(animationComponent);
  }
}
