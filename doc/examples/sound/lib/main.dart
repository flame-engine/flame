import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();
  runApp(MyGame(size).widget);
}

class Ball extends PositionComponent {
  final Size gameSize;
  final paint = Paint()..color = const Color(0xFFFFFFFF);

  bool forward = true;

  Ball(this.gameSize);

  @override
  void render(Canvas c) {
    c.drawOval(toRect(), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    x += (forward ? 1 : -1) * 100 * dt;

    if (x <= 0 || x + width >= gameSize.width) {
      if (forward) {
        x = gameSize.width - width - 1;
      } else {
        x = 1;
      }

      forward = !forward;
      Flame.audio.play('boin.mp3', volume: 1.0);
    }
  }
}

class MyGame extends BaseGame {
  MyGame(Size screenSize) {
    size = screenSize;
    _start();
  }

  void _start() async {
    Flame.audio.disableLog();
    Flame.audio.load('boin.mp3');
    Flame.audio.loop('music.mp3', volume: 0.4);

    add(Ball(size)
      ..y = (size.height / 2) - 50
      ..width = 100
      ..height = 100);
  }
}
