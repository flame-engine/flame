import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class RenderedTimeComponent extends TimerComponent {
  final TextPaint textPaint = TextPaint(
    config: const TextPaintConfig(
      color: Color(0xFFFFFFFF),
    ),
  );

  final double yOffset;

  RenderedTimeComponent(double period, {this.yOffset = 150})
      : super(
          period: period,
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
    add(RenderedTimeComponent(1));
  }

  @override
  void onDoubleTap() {
    add(RenderedTimeComponent(5, yOffset: 180));
  }
}
