import 'package:flame/gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.images.loadAll(['creature.png', 'chopper.png']);

  final Vector2 size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame with TapDetector {
  final animation = SpriteAnimation.sequenced(
    'chopper.png',
    4,
    textureSize: Vector2.all(48),
    stepTime: 0.15,
    loop: true,
  );

  void addAnimation(double x, double y) {
    final size = Vector2(291, 178);

    final animationComponent = SpriteAnimationComponent.sequenced(
      size,
      'creature.png',
      18,
      amountPerRow: 10,
      textureSize: size,
      stepTime: 0.15,
      loop: false,
      destroyOnFinish: true,
    );

    animationComponent.position = animationComponent.position - size / 2;
    add(animationComponent);
  }

  @override
  void onTapDown(TapDownDetails evt) {
    addAnimation(evt.globalPosition.dx, evt.globalPosition.dy);
  }

  MyGame(Vector2 screenSize) {
    size = screenSize;

    final spriteSize = Vector2.all(100.0);
    final animationComponent = SpriteAnimationComponent(spriteSize, animation);
    animationComponent.x = size.x / 2 - spriteSize.x;
    animationComponent.y = spriteSize.y;

    final reversedAnimationComponent = SpriteAnimationComponent(
      spriteSize,
      animation.reversed(),
    );
    reversedAnimationComponent.x = size.x / 2;
    reversedAnimationComponent.y = spriteSize.y;

    add(animationComponent);
    add(reversedAnimationComponent);
  }
}
