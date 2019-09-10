import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/events/gestures.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
}

class TapeableSquare extends PositionComponent with Tapeable {
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _grey = Paint()..color = const Color(0xFFA5A5A5);

  bool _beenPressed = false;

  TapeableSquare({double y = 100}) {
    x = width = height = 100;
    this.y = y;
  }

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    canvas.drawRect(toRect(), _beenPressed ? _grey : _white);
  }

  @override
  void onTapUp(TapUpDetails details) {
    _beenPressed = false;
  }

  @override
  void onTapDown(TapDownDetails details) {
    _beenPressed = true;
  }

  @override
  void onTapCancel() {
    _beenPressed = false;
  }
}

class MyGame extends BaseGame {
  MyGame() {
    add(TapeableSquare());
    add(TapeableSquare(y: 400));
  }
}
