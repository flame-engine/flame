import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyGame().widget);

class Palette {
  static const PaletteEntry white = BasicPalette.white;
  static const PaletteEntry red = PaletteEntry(Color(0xFFFF0000));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF0000FF));
}

class Square extends PositionComponent {
  static const SPEED = 0.25;

  Square(double size) {
    width = height = size;
    anchor = Anchor.center;
  }

  @override
  void resize(Size size) {
    x = size.width / 2;
    y = size.height / 2;
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    c.drawRect(Rect.fromLTWH(0, 0, width, height), Palette.white.paint);
    c.drawRect(Rect.fromLTWH(0, 0, 3, 3), Palette.red.paint);
    c.drawRect(Rect.fromLTWH(width / 2, height / 2, 3, 3), Palette.blue.paint);
  }

  @override
  void update(double t) {
    angle += SPEED * t;
    angle %= 2 * math.pi;
  }
}

class MyGame extends BaseGame {
  MyGame() {
    add(Square(64.0));
  }
}
