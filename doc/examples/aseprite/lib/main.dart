import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/components/animation_component.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyGame().widget);

class MyGame extends BaseGame {
  MyGame() {
    _start();
  }

  _start() async {
    Size size = await Flame.util.initialDimensions();

    final animation = await FlameAnimation.Animation.fromAsepriteData("chopper.png", "./assets/chopper.json");
    final animationComponent = AnimationComponent(100, 100, animation);

    animationComponent.x = (size.width / 2) - 50;
    animationComponent.y = (size.height / 2) - 50;

    add(animationComponent);
  }
}

