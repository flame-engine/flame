import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyGame().widget);

class Ball extends PositionComponent {
  final Size gameSize;
  final paint = Paint()..color = Color(0xFFFFFFFF);

  bool foward = true;

  Ball(this.gameSize);

  void render(Canvas c) {
    c.drawOval(this.toRect(), paint);
  }

  void update(double delta) {
    if (foward) {
      this.x += 100 * delta;
    } else {
      this.x -= 100 * delta;
    }

    if (this.x <= 0 || this.x + this.width >= gameSize.width) {
      if (foward)
        this.x = gameSize.width - this.width - 1;
      else
        this.x = 1;

      foward = !foward;
      print("boin");
      Flame.audio.play("boin.mp3", volume: 1.2);
    }
  }
}

class MyGame extends BaseGame {
  MyGame() {
    _start();
  }

  _start() async {
    Size size = await Flame.util.initialDimensions();

    Flame.audio.disableLog();
    Flame.audio.load("boin.mp3");
    Flame.audio.loop("music.mp3", volume: 0.4);

    add(Ball(size)
      ..y = (size.height / 2) - 50
      ..width = 100
      ..height = 100);
  }
}
