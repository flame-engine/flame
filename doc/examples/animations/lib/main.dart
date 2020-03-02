import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart' as flame_animation;
import 'package:flame/components/animation_component.dart';
import 'package:flutter/material.dart';

void main() async {
  final Size size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);

  await Flame.images.load('chopper.png');

  Flame.util.addGestureRecognizer(TapGestureRecognizer()
    ..onTapDown = (TapDownDetails evt) {
      game.addAnimation();
    });
}

class MyGame extends BaseGame {
  final animation = flame_animation.Animation.fromImage(
      Flame.images.fromCache('chopper.png'),
      frameCount: 4,
      frameWidth: 48,
      frameHeight: 48,
      stepTime: 0.15
  );

  void addAnimation() {
    final animationComponent = AnimationComponent(
        animation,
        width: 100,
        height: 100,
        x: size.width / 2 - 50,
        y: 200,
        destroyOnFinish: true
    );

    add(animationComponent);
  }

  MyGame(Size screenSize) {
    size = screenSize;

    final animationComponent = AnimationComponent(
        animation,
        width: 100,
        height: 100,
        x: size.width / 2 - 100,
        y: 100,
    );

    final reversedAnimationComponent = AnimationComponent(
        animation.reversed(),
        width: 100,
        height: 100,
        x: size.width / 2,
        y: 100,
    );

    add(animationComponent);
    add(reversedAnimationComponent);
  }
}
