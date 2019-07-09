import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/time.dart';
import 'package:flame/text_config.dart';
import 'package:flame/position.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);

  Flame.util.addGestureRecognizer(TapGestureRecognizer()
    ..onTapDown = (TapDownDetails evt) {
      game.countdown.start();
    });
}

class MyGame extends Game {
  final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));
  Timer countdown;
  Timer interval;

  int elapsedSecs = 0;

  MyGame() {
    countdown = Timer(2);
    interval = Timer(1, repeat: true, callback: () {
      elapsedSecs += 1;
    });
    interval.start();
  }

  @override
  void update(double dt) {
    countdown.update(dt);
    interval.update(dt);
  }

  @override
  void render(Canvas canvas) {
    textConfig.render(canvas, "Countdown: ${countdown.current.toString()}",
        Position(10, 100));
    textConfig.render(canvas, "Elapsed time: $elapsedSecs", Position(10, 150));
  }
}
