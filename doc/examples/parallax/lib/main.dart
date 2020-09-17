import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/vector2f.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  runApp(MyGame().widget);
}

class MyGame extends BaseGame {
  MyGame() {
    final images = [
      ParallaxImage('bg.png'),
      ParallaxImage('mountain-far.png'),
      ParallaxImage('mountains.png'),
      ParallaxImage('trees.png'),
      ParallaxImage('foreground-trees.png'),
    ];

    final parallaxComponent = ParallaxComponent(
      images,
      baseSpeed: Vector2F(20, 0),
      layerDelta: Vector2F(30, 0),
    );

    add(parallaxComponent);
  }
}
