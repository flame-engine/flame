import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart' as flame_animation;
import 'package:flame/components/animation_component.dart';
import 'package:flutter/material.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
  Flame.util.addGestureRecognizer(TapGestureRecognizer()
      ..onTapDown = (TapDownDetails evt) {
        game.addAnimation();
      });
}

class MyGame extends BaseGame {
  final animation = flame_animation.Animation.sequenced('chopper.png', 4,
      textureWidth: 48, textureHeight: 48, stepTime: 0.15);

  MyGame() {
    _start();
  }

  void addAnimation() {
    final animationComponent = AnimationComponent(100, 100, animation, destroyOnFinish: true);
    animationComponent.x = size.width / 2 - 50;
    animationComponent.y = 200;

    add(animationComponent);
  }

  void _start() async {
    final Size size = await Flame.util.initialDimensions();

    final animationComponent = AnimationComponent(100, 100, animation);
    animationComponent.x = size.width / 2 - 100;
    animationComponent.y = 100;

    final reversedAnimationComponent =
        AnimationComponent(100, 100, animation.reversed());
    reversedAnimationComponent.x = size.width / 2;
    reversedAnimationComponent.y = 100;

    add(animationComponent);
    add(reversedAnimationComponent);
  }
}
