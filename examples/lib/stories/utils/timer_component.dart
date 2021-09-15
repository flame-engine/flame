import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/timer.dart';
import 'package:flutter/material.dart';

class RenderedTimeComponent extends TimerComponent {
  final TextPaint textPaint = TextPaint(
    config: const TextPaintConfig(
      color: Color(0xFFFFFFFF),
    ),
  );

  RenderedTimeComponent(Timer timer) : super(timer);

  @override
  void render(Canvas canvas) {
    textPaint.render(
      canvas,
      'Elapsed time: ${timer.current}',
      Vector2(10, 150),
    );
  }
}

class TimerComponentGame extends FlameGame with TapDetector, DoubleTapDetector {
  @override
  void onTapDown(_) {
    add(RenderedTimeComponent(Timer(1)..start()));
  }

  @override
  void onDoubleTap() {
    add(RenderedTimeComponent(Timer(5)..start()));
  }
}
