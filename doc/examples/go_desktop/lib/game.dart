import 'package:flame/game.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class MyGame extends Game {
  static final Paint paint = Paint()..color = const Color(0xFFFFFFFF);

  var movingLeft = false;
  var movingRight = false;
  var movingUp = false;
  var movingDown = false;

  double x = 0;
  double y = 0;

  MyGame() {
    _start();
  }

  void _start() {
    RawKeyboard.instance.addListener((RawKeyEvent e) {
      final bool isKeyDown = e is RawKeyDownEvent;

      final keyLabel = e.data.logicalKey.keyLabel;

      if (keyLabel == 'a') {
        movingLeft = isKeyDown;
      }

      if (keyLabel == 'd') {
        movingRight = isKeyDown;
      }

      if (keyLabel == 'w') {
        movingUp = isKeyDown;
      }

      if (keyLabel == 's') {
        movingDown = isKeyDown;
      }
    });
  }

  @override
  void update(double dt) {
    if (movingLeft) {
      x -= 100 * dt;
    } else if (movingRight) {
      x += 100 * dt;
    }

    if (movingUp) {
      y -= 100 * dt;
    } else if (movingDown) {
      y += 100 * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(x, y, 100, 100), paint);
  }
}
