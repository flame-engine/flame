import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/timer.dart';
import 'package:flutter/material.dart';

class TimerGame extends FlameGame with TapDetector {
  final TextPaint textConfig = TextPaint(
    config: const TextPaintConfig(
      color: Color(0xFFFFFFFF),
    ),
  );
  late Timer countdown;
  late Timer interval;

  int elapsedSecs = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
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
    super.update(dt);
    countdown.update(dt);
    interval.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textConfig.render(
      canvas,
      'Countdown: ${countdown.current}',
      Vector2(10, 100),
    );
    textConfig.render(canvas, 'Elapsed time: $elapsedSecs', Vector2(10, 150));
  }
}
