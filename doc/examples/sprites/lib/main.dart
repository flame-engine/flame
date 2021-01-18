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
    List.generate(500, (i) => SpriteComponent.fromImage(Vector2.all(32), image))
        .forEach((sprite) {
      sprite.x = r.nextInt(size.x.toInt()).toDouble();
      sprite.y = r.nextInt(size.y.toInt()).toDouble();
      add(sprite);
    });
  }
}
