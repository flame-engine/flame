import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(
      GameWidget(
        game: MyGame(),
      ),
    );

class MyGame extends Game with KeyboardEvents {
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);

  Rect _rect = const Rect.fromLTWH(0, 100, 100, 100);
  int _dir = 0;

  @override
  void update(double dt) {
    _rect = _rect.translate(
      _dir * dt * 100,
      0,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_rect, _white);
  }

  @override
  void onKeyEvent(RawKeyEvent e) {
    final isKeyDown = e is RawKeyDownEvent;
    if (e.data.keyLabel == 'a') {
      _dir = isKeyDown ? -1 : 0;
    } else if (e.data.keyLabel == 'd') {
      _dir = isKeyDown ? 1 : 0;
    }
  }
}
