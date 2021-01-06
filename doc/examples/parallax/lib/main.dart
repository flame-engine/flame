import 'package:flame/flame.dart';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class MyGame extends BaseGame {
  final _imageNames = [
    'bg.png',
    'mountain-far.png',
    'mountains.png',
    'trees.png',
    'foreground-trees.png',
  ];

  @override
  Future<void> onLoad() async {
    final parallax = await ParallaxComponent.load(
      _imageNames,
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
    add(parallax);
  }
}
