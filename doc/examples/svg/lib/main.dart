import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/svg.dart';
import 'package:flame/components/component.dart' show SvgComponent;

import 'package:flutter/material.dart';

void main() => runApp(MyGame());

class MyGame extends BaseGame {

  SvgComponent android = null;

  MyGame() {
    _start();
  }

  _start() async {
    Size size = await Flame.util.initialDimensions();

    Svg svg = Svg("android.svg");
    android = SvgComponent.fromSvg(100, 100, svg);
    android.x = 100;
    android.y = 100;

    add(android);
  }
}
