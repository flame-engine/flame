import 'package:flame/game.dart';
import 'package:flame/flare_animation.dart';

import 'package:flutter/material.dart';

void main() => runApp(MyGame().widget);

class MyGame extends BaseGame {

  FlareAnimation flareAnimation;
  bool loaded = false;

  MyGame() {
    _start();
  }

  void _start() async {
    flareAnimation = await FlareAnimation.load("assets/Success_Check.flr");
    loaded = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    flareAnimation.render(canvas);
  }
}

