import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/svg.dart';
import 'package:flame/position.dart';
import 'package:flame/components/component.dart' show SvgComponent;
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/text_config.dart';

import 'package:flutter/material.dart';

void main() async {
  await Flame.util.initialDimensions();

  runApp(MyGame().widget);
}

class AndroidComponent extends SvgComponent with Resizable {
  static const int SPEED = 150;
  int xDirection = 1;
  int yDirection = 1;

  AndroidComponent() : super.fromSvg(100, 100, Svg('android.svg'));

  @override
  void update(double dt) {
    if (size == null) {
      return;
    }

    x += xDirection * SPEED * dt;

    final rect = toRect();

    if ((x <= 0 && xDirection == -1) ||
        (rect.right >= size.width && xDirection == 1)) {
      xDirection = xDirection * -1;
    }

    y += yDirection * SPEED * dt;

    if ((y <= 0 && yDirection == -1) ||
        (rect.bottom >= size.height && yDirection == 1)) {
      yDirection = yDirection * -1;
    }
  }
}

class MyGame extends BaseGame {
  final TextConfig fpsTextConfig =
      const TextConfig(color: const Color(0xFFFFFFFF));

  MyGame() {
    _start();
  }

  @override
  bool debugMode() => true;

  void _start() {
    final AndroidComponent android = AndroidComponent();
    android.x = 100;
    android.y = 400;

    final AndroidComponent android2 = AndroidComponent();
    android2.x = 100;
    android2.y = 400;
    android2.yDirection = -1;

    final AndroidComponent android3 = AndroidComponent();
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
      fpsTextConfig.render(canvas, fps(120).toString(), Position(0, 50));
    }
  }
}
