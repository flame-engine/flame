import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/tapable.dart';

void main() {
  final game = MyGame();

  final widget = Container(
    padding: const EdgeInsets.all(50),
    color: const Color(0xFFA9A9A9),
    child: game.widget,
  );

  runApp(widget);
}

class TapableSquare extends PositionComponent with Tapable {
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _grey = Paint()..color = const Color(0xFFA5A5A5);

  bool _beenPressed = false;

  TapableSquare({double y = 100, double x = 100}) {
    width = height = 100;
    this.x = x;
    this.y = y;
  }

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

class MyGame extends BaseGame with HasTapableComponents {
  MyGame() {
    add(TapableSquare(y: 100));
    add(TapableSquare(y: 250));
  }
}
