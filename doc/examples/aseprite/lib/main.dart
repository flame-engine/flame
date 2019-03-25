import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart' as flame_animation;
import 'package:flame/components/animation_component.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyGame().widget);

class MyGame extends BaseGame {
  MyGame() {
    _start();
  }

  void _start() async {
    final Size size = await Flame.util.initialDimensions();

    final animation = await flame_animation.Animation.fromAsepriteData(
        'chopper.png', 'chopper.json');
    final animationComponent = AnimationComponent(200, 200, animation);

    animationComponent.x = (size.width / 2) - 100;
    animationComponent.y = (size.height / 2) - 100;

    add(animationComponent);
  }
}
