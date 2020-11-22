import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_box_component.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';

void main() async {
  final Vector2 size = await Flame.util.initialDimensions();
  runApp(MyGame(size).widget);
}

TextConfig regular = TextConfig(color: BasicPalette.white.color);
TextConfig tiny = regular.withFontSize(12.0);

class MyTextBox extends TextBoxComponent {
  MyTextBox(String text)
      : super(
          text,
          config: tiny,
          boxConfig: TextBoxConfig(
            timePerChar: 0.05,
            growingBox: true,
            margins: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
        );

  @override
  void drawBackground(Canvas c) {
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = const Color(0xFFFF00FF));
    final margin = boxConfig.margins;
    final Rect innerRect = Rect.fromLTWH(
      margin.left,
      margin.top,
      width - margin.horizontal,
      height - margin.vertical,
    );
    c.drawRect(
        innerRect,
        Paint()
          ..color = BasicPalette.white.color
          ..style = PaintingStyle.stroke);
  }
}

class MyGame extends BaseGame {
  MyGame(Vector2 screenSize) {
    size = screenSize;
    add(TextComponent('Hello, Flame', config: regular)
      ..anchor = Anchor.topCenter
      ..x = size.x / 2
      ..y = 32.0);

    add(TextComponent('center', config: tiny)
      ..anchor = Anchor.center
      ..position = size / 2);

    add(TextComponent('bottomRight', config: tiny)
      ..anchor = Anchor.bottomRight
      ..position = size);

    add(MyTextBox(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eget ligula eu lectus lobortis condimentum.',
    )
      ..anchor = Anchor.bottomLeft
      ..y = size.y);
  }
}
