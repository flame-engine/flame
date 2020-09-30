import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/components/position_component.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Vector2 size = await Flame.util.initialDimensions();
  runApp(MyGame(size).widget);
}

class Ball extends PositionComponent {
  final Vector2 gameSize;
  final paint = Paint()..color = const Color(0xFFFFFFFF);

  bool forward = true;

  Ball(this.gameSize);

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawOval(size.toRect(), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    x += (forward ? 1 : -1) * 100 * dt;

    if (x <= 0 || x + width >= gameSize.x) {
      if (forward) {
        x = gameSize.x - width - 1;
      } else {
        x = 1;
      }

      forward = !forward;
      Flame.audio.play('boin.mp3', volume: 1.0);
    }
  }
}

class MyGame extends BaseGame {
  MyGame(Vector2 screenSize) {
    size = screenSize;

    Flame.audio.disableLog();
    Flame.audio.load('boin.mp3');
    Flame.audio.loop('music.mp3', volume: 0.4);

    add(Ball(size)
      ..y = (size.y / 2) - 50
      ..size = Vector2.all(100));
  }
}
