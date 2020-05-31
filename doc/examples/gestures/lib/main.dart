import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
}

/// Includes an example including basic detectors
class MyGame extends Game
    with TapDetector, DoubleTapDetector, PanDetector, LongPressDetector {
  final _whitePaint = BasicPalette.white.paint;
  final _bluePaint = Paint()..color = const Color(0xFF0000FF);
  final _greenPaint = Paint()..color = const Color(0xFF00FF00);
  final _redPaint = Paint()..color = const Color(0xFFFF0000);

  Paint _paint;

  Rect _rect = const Rect.fromLTWH(50, 50, 50, 50);

  MyGame() {
    _paint = _whitePaint;
  }

  @override
  void onTap() {
    _paint = _paint == _whitePaint ? _bluePaint : _whitePaint;
  }

  @override
  void onDoubleTap() {
    _paint = _greenPaint;
  }

  @override
  void onLongPress() {
    _paint = _redPaint;
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    _rect = _rect.translate(details.delta.dx, details.delta.dy);
  }

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_rect, _paint);
  }
}
