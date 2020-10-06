import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/text_config.dart';

import 'package:flutter/material.dart' hide Image;

import 'dart:ui';

void main() async {
  Flame.initializeWidget();
  await Flame.util.initialDimensions();

  final myGame = MyGame();
  runApp(myGame.widget);
}

class AndroidComponent extends SpriteComponent with Resizable {
  static const int SPEED = 150;
  int xDirection = 1;
  int yDirection = 1;

  AndroidComponent(Image image) : super.fromImage(Vector2.all(100), image);

  @override
  void update(double dt) {
    super.update(dt);
    if (gameSize == null) {
      return;
    }

    x += xDirection * SPEED * dt;

    final rect = toRect();

    if ((x <= 0 && xDirection == -1) ||
        (rect.right >= gameSize.x && xDirection == 1)) {
      xDirection = xDirection * -1;
    }

    y += yDirection * SPEED * dt;

    if ((y <= 0 && yDirection == -1) ||
        (rect.bottom >= gameSize.y && yDirection == 1)) {
      yDirection = yDirection * -1;
    }
  }
}

class MyGame extends BaseGame {
  final fpsTextConfig = TextConfig(color: const Color(0xFFFFFFFF));

  @override
  bool debugMode() => true;

  @override
  Future<void> onLoad() async {
    final androidImage = await images.load('android.png');

    final android = AndroidComponent(androidImage);
    android.x = 100;
    android.y = 400;

    final android2 = AndroidComponent(androidImage);
    android2.x = 100;
    android2.y = 400;
    android2.yDirection = -1;

    final android3 = AndroidComponent(androidImage);
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

    if (debugMode()) {
      fpsTextConfig.render(canvas, fps(120).toString(), Vector2(0, 50));
    }
  }
}
