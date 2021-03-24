import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart' show RawKeyDownEvent, RawKeyEvent;

class KeyboardGame extends Game with KeyboardEvents {
  static final Paint _white = BasicPalette.white.paint();
  static const int speed = 200;

  Rect _rect = const Rect.fromLTWH(0, 100, 100, 100);
  final Vector2 velocity = Vector2(0, 0);

  @override
  void update(double dt) {
    final displacement = velocity * (speed * dt);
    _rect = _rect.translate(displacement.x, displacement.y);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_rect, _white);
  }

  @override
  void onKeyEvent(RawKeyEvent e) {
    final isKeyDown = e is RawKeyDownEvent;
    if (e.data.keyLabel == 'a') {
      velocity.x = isKeyDown ? -1 : 0;
    } else if (e.data.keyLabel == 'd') {
      velocity.x = isKeyDown ? 1 : 0;
    } else if (e.data.keyLabel == 'w') {
      velocity.y = isKeyDown ? -1 : 0;
    } else if (e.data.keyLabel == 's') {
      velocity.y = isKeyDown ? 1 : 0;
    }
  }
}
