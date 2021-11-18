import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class TimerComponentExample extends FlameGame
    with TapDetector, DoubleTapDetector {
  static const String description = '''
    This examples showcases the `TimerComponent`.\n\n
    Tap to start a timer that lives for one second and double tap to start
    another timer that lives for 5 seconds.
  ''';

  RenderedTimeComponent? tapComponent;
  RenderedTimeComponent? doubleTapComponent;

  @override
  void onTap() {
    tapComponent?.removeFromParent();
    tapComponent = RenderedTimeComponent(1);
    add(tapComponent!);
  }

  @override
  void onDoubleTap() {
    doubleTapComponent?.removeFromParent();
    doubleTapComponent = RenderedTimeComponent(5, yOffset: 180);
    add(doubleTapComponent!);
  }
}

class RenderedTimeComponent extends TimerComponent {
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 20),
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
      Vector2(30, yOffset),
    );
  }
}
