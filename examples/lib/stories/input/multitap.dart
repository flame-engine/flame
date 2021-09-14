import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

/// Includes an example including advanced detectors
class MultitapGame extends FlameGame with MultiTouchTapDetector {
  static final whitePaint = BasicPalette.white.paint();
  static final tapSize = Vector2.all(50);

  final Map<int, Rect> taps = {};

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    taps[pointerId] = info.eventPosition.game.toPositionedRect(tapSize);
  }

  @override
  void onTapUp(int pointerId, _) {
    taps.remove(pointerId);
  }

  @override
  void onTapCancel(int pointerId) {
    taps.remove(pointerId);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    taps.values.forEach((rect) {
      canvas.drawRect(rect, whitePaint);
    });
  }
}
