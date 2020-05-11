import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

void main() {
  final game = MyGame();

  runApp(game.widget);
}

class Palette {
  static const PaletteEntry white = BasicPalette.white;
  static const PaletteEntry red = PaletteEntry(Color(0xFFFF0000));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF0000FF));
}

class Square extends PositionComponent with HasGameRef<MyGame> {
  static const SPEED = 0.25;

  @override
  void resize(Size size) {
    super.resize(size);
    x = size.width / 2;
    y = size.height / 2;
    anchor = Anchor.center;
  }

  @override
  void render(Canvas c) {
    super.render(c);

    c.drawRect(Rect.fromLTWH(0, 0, width, height), Palette.white.paint);
    c.drawRect(const Rect.fromLTWH(0, 0, 3, 3), Palette.red.paint);
    c.drawRect(Rect.fromLTWH(width / 2, height / 2, 3, 3), Palette.blue.paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += SPEED * dt;
    angle %= 2 * math.pi;
  }

  @override
  void onMount() {
    width = height = gameRef.squareSize;
    anchor = Anchor.center;
  }
}

class MyGame extends BaseGame with TapDetector {
  final double squareSize = 128;
  bool running = true;

  MyGame() {
    add(Square());
  }

  @override
  void onTap() {
    if (running) {
      pauseEngine();
    } else {
      resumeEngine();
    }

    running = !running;
  }
}
