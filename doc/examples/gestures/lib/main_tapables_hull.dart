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
      Vector2(-0.5, 0),
      Vector2(-0.4, 0.3),
      Vector2(0, 0.5),
      Vector2(0.3, 0.45),
      Vector2(0.5, 0),
      Vector2(0.3, -0.4),
      Vector2(0, -0.5),
      Vector2(-0.4, -0.4),
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
