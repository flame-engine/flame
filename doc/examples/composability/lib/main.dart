import 'package:flame/anchor.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class Square extends PositionComponent with HasGameRef<MyGame> {
  Square(Vector2 position, Vector2 size, {double angle = 0}) {
    this.position.setFrom(position);
    this.size.setFrom(size);
    this.angle = angle;
  }
}

class ParentSquare extends Square {
  ParentSquare(Vector2 position, Vector2 size) : super(position, size);

  @override
  void onMount() {
    super.onMount();
    createChildren();
  }

  void createChildren() {
    // All positions here are in relation to the parent's position
    final children = [
      Square(Vector2(100, 100), Vector2(50, 50), angle: 2),
      Square(Vector2(160, 100), Vector2(50, 50), angle: 3),
      Square(Vector2(170, 150), Vector2(50, 50), angle: 4),
      Square(Vector2(70, 200), Vector2(50, 50), angle: 5),
    ];

    children.forEach(addChild);
  }
}

class MyGame extends BaseGame {
  ParentSquare _parent;

  @override
  bool debugMode() => true;

  MyGame() {
    _parent = ParentSquare(Vector2.all(200), Vector2.all(300));
    _parent.anchor = Anchor.center;
    add(_parent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _parent.angle += dt;
  }
}
