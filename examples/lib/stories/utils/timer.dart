import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/timer.dart';
import 'package:flame/gestures.dart';

class TimerGame extends Game with TapDetector {
  final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));
  Timer countdown;
  Timer interval;

  int elapsedSecs = 0;

  TimerGame() {
    countdown = Timer(2);
    interval = Timer(
      1,
      callback: () => elapsedSecs += 1,
      repeat: true,
    );
    interval.start();
  }

  @override
  void onTapDown(_) {
    countdown.start();
  }

  @override
  void update(double dt) {
    countdown.update(dt);
    interval.update(dt);
  }

  @override
  void render(Canvas canvas) {
    textConfig.render(
      canvas,
      'Countdown: ${countdown.current}',
      Vector2(10, 100),
    );
    textConfig.render(canvas, 'Elapsed time: $elapsedSecs', Vector2(10, 150));
  }
}
