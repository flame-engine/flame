import 'package:flame/anchor.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/components/mixins/tapable.dart';

void main() {
  runApp(
    Container(
      padding: const EdgeInsets.all(50),
      color: const Color(0xFFA9A9A9),
      child: GameWidget(
        game: MyGame(),
      ),
    ),
  );
}

class TapablePolygon extends PositionComponent with Tapable {

  TapablePolygon({Vector2 position}) {
    size = Vector2.all(100);
    hull = [
      Vector2(-50, 0),
      Vector2(-40, 30),
      Vector2(0, 50),
      Vector2(30, 45),
      Vector2(50, 0),
      Vector2(30, -40),
      Vector2(0, -50),
      Vector2(-40, -40),
    ];
    this.position = position ?? Vector2.all(100);
  }

  @override
  bool onTapUp(TapUpDetails details) {
    return true;
  }

  @override
  bool onTapDown(TapDownDetails details) {
    angle += 1.0;
    return true;
  }

  @override
  bool onTapCancel() {
    return true;
  }
}

class MyGame extends BaseGame with HasTapableComponents {
  MyGame() {
    debugMode = true;
    add(TapablePolygon()..anchor = Anchor.center);
    add(TapablePolygon()..y = 350);
  }
}
