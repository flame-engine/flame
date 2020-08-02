import 'package:flame/animation.dart' as flame_animation;
import 'package:flame/components/animation_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  final animation = flame_animation.Animation.sequenced(
    'chopper.png',
    4,
    textureWidth: 48,
    textureHeight: 48,
    stepTime: 0.15,
  );

  AnimationComponent buildAnimation() {
    final ac = AnimationComponent(100, 100, animation);
    ac.x = size.width / 2 - ac.width / 2;
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
