import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

final _regular = TextConfig(color: BasicPalette.white.color);
final _tiny = _regular.withFontSize(12.0);

final _white = Paint()
  ..color = BasicPalette.white.color
  ..style = PaintingStyle.stroke;

class MyTextBox extends TextBoxComponent {
  MyTextBox(String text)
      : super(
          text,
          config: _tiny,
          boxConfig: TextBoxConfig(
            timePerChar: 0.05,
            growingBox: true,
            margins: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
        );

  @override
  void drawBackground(Canvas c) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = const Color(0xFFFF00FF));
    final margin = boxConfig.margins;
    final innerRect = Rect.fromLTWH(
      margin.left,
      margin.top,
      width - margin.horizontal,
      height - margin.vertical,
    );
    c.drawRect(innerRect, _white);
  }
}

class TextGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    add(
      TextComponent('Hello, Flame', config: _regular)
        ..anchor = Anchor.topCenter
        ..x = size.x / 2
        ..y = 32.0,
    );

    add(
      TextComponent('center', config: _tiny)
        ..anchor = Anchor.center
        ..position = size / 2,
    );

    add(
      TextComponent('bottomRight', config: _tiny)
        ..anchor = Anchor.bottomRight
        ..position = size,
    );

    add(
      MyTextBox(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eget ligula eu lectus lobortis condimentum.',
      )
        ..anchor = Anchor.bottomLeft
        ..y = size.y,
    );
  }
}
