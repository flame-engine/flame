import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';

class ExampleGame extends Game with HasWidgetsOverlay, TapDetector {
  bool isPaused = false;

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(100, 100, 100, 100), Paint()..color = const Color(0xFFFFFFFF));
  }

  @override
  void onTap() {
    if (isPaused) {
      removeWidgetOverlay("PauseMenu");
      isPaused = false;
    } else {
      addWidgetOverlay(
          "PauseMenu",
          Container(
              width: 100,
              height: 100,
              color: const Color(0xFFFF0000),
              child: const Text("Paused"),
          ),
      );
      isPaused = true;
    }
  }
}

void main() {
  runApp(ExampleGame().widget);
}

