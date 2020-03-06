import 'package:flame/game.dart';
import 'package:flame/svg.dart';
import 'package:flame/position.dart';
import 'package:flame/components/component.dart' show SvgComponent;

import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final game = MyGame();
  runApp(game.widget);
}

class MyGame extends BaseGame {
  Svg svgInstance;
  SvgComponent android;

  MyGame() {
    _start();
  }

  void _start() {
    svgInstance = Svg('android.svg');
    android = SvgComponent(
      svgInstance,
      width:  100,
      height: 100,
      x:      10,
      y:      10,
    );

    add(android);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    svgInstance.renderPosition(canvas, Position(100, 200), 300, 300);
  }
}
