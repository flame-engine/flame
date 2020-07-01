import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_box_component.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';

void main() async {
  final Size size = await Flame.util.initialDimensions();
  runApp(MyGame(size).widget);
}

TextConfig regular = TextConfig(color: BasicPalette.white.color);
TextConfig tiny = regular.withFontSize(12.0);

class MyTextBox extends TextBoxComponent {
  MyTextBox(String text)
      : super(text, config: tiny, boxConfig: TextBoxConfig(timePerChar: 0.05));

  @override
  void drawBackground(Canvas c) {
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = const Color(0xFFFF00FF));
    c.drawRect(
        rect.deflate(boxConfig.margin),
        Paint()
          ..color = BasicPalette.black.color
          ..style = PaintingStyle.stroke);
  }
}

class MyGame extends BaseGame {
  MyGame(Size screenSize) {
    size = screenSize;
    add(TextComponent('Hello, Flame', config: regular)
      ..anchor = Anchor.topCenter
      ..x = size.width / 2
      ..y = 32.0);

    add(TextComponent('center', config: tiny)
      ..anchor = Anchor.center
      ..x = size.width / 2
      ..y = size.height / 2);

    add(TextComponent('bottomRight', config: tiny)
      ..anchor = Anchor.bottomRight
      ..x = size.width
      ..y = size.height);

    add(MyTextBox(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eget ligula eu lectus lobortis condimentum.')
      ..anchor = Anchor.bottomLeft
      ..y = size.height);
  }
}
