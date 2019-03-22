import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/components/animation_component.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyGame().widget);

class MyGame extends BaseGame {
  MyGame() {
    _start();
  }

  _start() async {
    Size size = await Flame.util.initialDimensions();

    final animation = await FlameAnimation.Animation.sequenced('chopper.png', 4, textureWidth: 48, textureHeight: 48, stepTime: 0.15);

    final animationComponent = AnimationComponent(100, 100, animation);
    animationComponent.x = size.width / 2 - 100;
    animationComponent.y = 100;

    final reversedAnimationComponent = AnimationComponent(100, 100, animation.reversed());
    reversedAnimationComponent.x = size.width / 2;
    reversedAnimationComponent.y = 100;


    add(animationComponent);
    add(reversedAnimationComponent);
  }
}

