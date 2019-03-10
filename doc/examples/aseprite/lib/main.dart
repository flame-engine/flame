import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/components/animation_component.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyGame());

class MyGame extends BaseGame {
  MyGame() {
    _start();
  }

  _start() async {
    Size size = await Flame.util.initialDimensions();

    final animation = await FlameAnimation.Animation.fromAsepriteData(
        'chopper.png', 'chopper.json');
    final animationComponent = AnimationComponent(200, 200, animation);

    animationComponent.x = (size.width / 2) - 100;
    animationComponent.y = (size.height / 2) - 100;

    add(animationComponent);
  }
}
