import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
}

class MyGame extends Game with TapDetector, DoubleTapDetector, PanDetector {
  final _whitePaint = Paint()..color = const Color(0xFFFFFFFF);
  final _bluePaint = Paint()..color = const Color(0xFF0000FF);
  final _greenPaint = Paint()..color = const Color(0xFF00FF00);

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
