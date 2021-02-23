import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = MyGame();
  runApp(
    GameWidget(
      game: game,
    ),
  );
}

class MyGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    final r = Random();
    final image = await images.load('test.png');
    List.generate(
      500,
      (i) => SpriteComponent(
        position: Vector2(
          r.nextInt(size.x.toInt()).toDouble(),
          r.nextInt(size.x.toInt()).toDouble(),
        ),
        size: Vector2.all(32),
        sprite: Sprite(image),
      ),
    ).forEach(add);
  }
}
