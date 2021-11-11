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

  final double yOffset;

  RenderedTimeComponent(Timer timer, {this.yOffset = 150})
      : super(
          timer,
          removeOnFinish: true,
        );

  @override
  void render(Canvas canvas) {
    textPaint.render(
      canvas,
      'Elapsed time: ${timer.current.toStringAsFixed(3)}',
      Vector2(10, yOffset),
    );
  }
}

class TimerComponentGame extends FlameGame with TapDetector, DoubleTapDetector {
  @override
  void onTap() {
    add(RenderedTimeComponent(Timer(1)..start()));
  }

  @override
  void onDoubleTap() {
    add(RenderedTimeComponent(Timer(5)..start(), yOffset: 180));
  }
}
