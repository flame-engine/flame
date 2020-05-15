import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
}

/// Includes an example including advanced detectors
class MyGame extends Game with MultiTouchTapDetector {
  final _whitePaint = BasicPalette.white.paint;

  Paint _paint;

  final Map<int, Rect> _taps = {};

  MyGame() {
    _paint = _whitePaint;
  }

  @override
  void onTapDown(int pointerId, TapDownDetails details) {
    _taps[pointerId] = Rect.fromLTWH(
      details.globalPosition.dx,
      details.globalPosition.dy,
      50,
      50,
    );
  }

  @override
  void onTapUp(int pointerId, _) {
    _taps.remove(pointerId);
  }

  @override
  void onTapCancel(int pointerId) {
    _taps.remove(pointerId);
  }

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    _taps.values.forEach((rect) {
      canvas.drawRect(rect, _paint);
    });
  }
}
