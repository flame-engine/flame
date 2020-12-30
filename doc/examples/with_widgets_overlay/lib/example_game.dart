import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';

import 'package:flutter/material.dart';

class ExampleGame extends Game with TapDetector {
  @override
  void update(double dt) {}

  @override
  Future<void> onLoad() async {
    print('game loaded');
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(100, 100, 100, 100),
      Paint()..color = BasicPalette.white.color,
    );
  }

  @override
  void onTap() {
    if (overlays.isActive('PauseMenu')) {
      overlays.remove('PauseMenu');
    } else {
      overlays.add('PauseMenu');
    }
  }
}
