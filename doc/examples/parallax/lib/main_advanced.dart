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
  final _layersMeta = {
    'bg.png': 1.0,
    'mountain-far.png': 1.5,
    'mountains.png': 2.3,
    'trees.png': 3.8,
    'foreground-trees.png': 6.6,
  };

  @override
  Future<void> onLoad() async {
    final layers = _layersMeta.entries.map(
      (e) => ParallaxLayer.load(
        e.key,
        velocityMultiplier: Vector2(e.value, 1.0),
      ),
    );
    final parallax = ParallaxComponent(
      await Future.wait(layers),
      baseVelocity: Vector2(20, 0),
    );
    add(parallax);
  }
}
