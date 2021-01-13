import 'package:flame/components/mixins/collidable.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/extensions.dart';
import 'package:flame/components.dart';

import 'package:flutter/material.dart' hide Image;

import 'dart:ui';

void main() async {
  Flame.initializeWidget();

  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class CollidableRock extends SpriteComponent with Hitbox, Collidable {
  static const int SPEED = 150;
  Vector2 _gameSize;
  int xDirection = 1;
  int yDirection = 1;

  CollidableRock(Image image) : super.fromImage(Vector2.all(100), image) {
    hasScreenCollision = true;
    shape = [
      Vector2(0, 1),
      Vector2(1, 0),
      Vector2(0, -1),
      Vector2(-1, 0),
    ];
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_gameSize == null) {
      return;
    }

    x += xDirection * SPEED * dt;

    final rect = toRect();

    if ((x <= 0 && xDirection == -1) ||
        (rect.right >= _gameSize.x && xDirection == 1)) {
      xDirection = xDirection * -1;
    }

    y += yDirection * SPEED * dt;

    if ((y <= 0 && yDirection == -1) ||
        (rect.bottom >= _gameSize.y && yDirection == 1)) {
      yDirection = yDirection * -1;
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    _gameSize = gameSize;
  }

  @override
  void collisionCallback(List<Vector2> points, Collidable other) {
    print("Collision at $points");
  }
}

class MyGame extends BaseGame {
  final fpsTextConfig = TextConfig(color: const Color(0xFFFFFFFF));

  @override
  bool debugMode = true;

  @override
  Future<void> onLoad() async {
    final androidImage = await images.load('android.png');

    final android = CollidableRock(androidImage);
    android.x = 100;
    android.y = 400;

    final android2 = CollidableRock(androidImage);
    android2.x = 100;
    android2.y = 400;
    android2.yDirection = -1;

    final android3 = CollidableRock(androidImage);
    android3.x = 100;
    android3.y = 400;
    android3.xDirection = -1;

    add(android);
    add(android2);
    add(android3);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (debugMode) {
      fpsTextConfig.render(canvas, fps(120).toString(), Vector2(0, 50));
    }
  }
}
