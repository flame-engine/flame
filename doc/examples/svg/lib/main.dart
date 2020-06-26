import 'package:flame/game.dart';
import 'package:flame/svg.dart';
import 'package:flame/vector2d.dart';
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
    android = SvgComponent.fromSvg(100, 100, svgInstance);
    android.x = 100;
    android.y = 100;

    add(android);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    svgInstance.renderPosition(canvas, Vector2d(100, 200), 300, 300);
  }
}
