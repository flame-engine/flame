import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components/component.dart';
import 'package:flame/effects/effects.dart';
import 'package:flame/position.dart';

class Square extends PositionComponent {
  static final _paint = Paint()..color = Color(0xFFFFFFFF);

  Square() {
    width = 100;
    height = 100;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(toRect(), _paint);
  }
}

class MyGame extends BaseGame  with TapDetector {
  Square square;
  MyGame() {
    add(
        square = Square()
        ..x = 100
        ..y = 100
    );
  }

  @override
  void onTapUp(details) {
    square.addEffect(MoveEffect(
            destination: Position(
                details.localPosition.dx,
                details.localPosition.dy,
            ),
            speed: 250.0,
            curve: Curves.easeOutQuad,
    ));
  }
}

void main() {
  runApp(MyGame().widget);
}

