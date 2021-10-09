import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  @override
  void render(Canvas canvas) {
    canvas.drawRect(toRect(), Paint()..color = Colors.white);
  }
}

class SpaceShooterGame extends FlameGame {
  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    add(
      Player()
        ..x = size.x / 2
        ..y = size.y / 2
        ..width = 50
        ..height = 100
        ..anchor = Anchor.center,
    );
  }
}

class MyGame extends StatelessWidget {
  const MyGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: SpaceShooterGame());
  }
}
