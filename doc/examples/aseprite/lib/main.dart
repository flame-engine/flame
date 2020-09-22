import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Vector2 size = await Flame.util.initialDimensions();
  runApp(MyGame(size).widget);
}

class MyGame extends BaseGame {
  MyGame(Vector2 screenSize) {
    size = screenSize;
    _start();
  }

  void _start() async {
    final animation = await SpriteAnimation.fromAsepriteData(
      'chopper.png',
      'chopper.json',
    );
    final animationComponent = SpriteAnimationComponent(200, 200, animation)
      ..setPosition(size / 2 - Vector2(100, 100));

    add(animationComponent);
  }
}
