import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components/position_component.dart';
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

  TapableSquare({Vector2 position}) {
    size = Vector2.all(100);
    this.position = position ?? Vector2.all(100);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _beenPressed ? _grey : _white);
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
    add(TapableSquare());
    add(TapableSquare()..y = 250);
  }
}
