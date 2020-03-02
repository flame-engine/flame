import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart' as flame_animation;
import 'package:flame/components/animation_component.dart';
import 'package:flutter/material.dart';

void main() async {
  final Size size = await Flame.util.initialDimensions();

  await Flame.images.load('chopper.png');

  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  final animation = flame_animation.Animation.fromImage(
      Flame.images.fromCache('chopper.png'),
      frameCount: 4,
      frameWidth: 48,
      frameHeight: 48,
      stepTime: 0.15
  );

  AnimationComponent buildAnimation() {
    final ac = AnimationComponent(
        animation,
        width: 100,
        height: 100,
        x: size.width / 2 - 100 / 2
    );
    return ac;
  }

  MyGame(Size screenSize) {
    size = screenSize;

    final regular = buildAnimation();
    regular.y = 100;
    add(regular);

    final flipX = buildAnimation();
    flipX.y = 300;
    flipX.renderFlipX = true;
    add(flipX);

    final flipY = buildAnimation();
    flipY.y = 500;
    flipY.renderFlipY = true;
    add(flipY);
  }
}
