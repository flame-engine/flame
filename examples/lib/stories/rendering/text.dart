import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

final _regularTextConfig = TextStyle(color: BasicPalette.white.color);
final _regular = TextPaint(style: _regularTextConfig);
final _tiny = TextPaint(style: _regularTextConfig.copyWith(fontSize: 12.0));
final _shaded = TextPaint(
  style: TextStyle(
    color: BasicPalette.white.color,
    fontSize: 40.0,
    shadows: const [
      Shadow(color: Colors.red, offset: Offset(2, 2), blurRadius: 2),
      Shadow(color: Colors.yellow, offset: Offset(4, 4), blurRadius: 4),
    ],
  ),
);

final _white = Paint()
  ..color = BasicPalette.white.color
  ..style = PaintingStyle.stroke;

class MyTextBox extends TextBoxComponent {
  MyTextBox(String text)
      : super(
          text,
          textRenderer: _regular,
          boxConfig: TextBoxConfig(
            maxWidth: 400,
            timePerChar: 0.05,
            growingBox: true,
            margins: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
        );

  @override
  void drawBackground(Canvas c) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = Colors.amber);
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

class TextGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      TextComponent('Hello, Flame', textRenderer: _regular)
        ..anchor = Anchor.topCenter
        ..x = size.x / 2
        ..y = 32.0,
    );

    add(
      TextComponent('Text with shade', textRenderer: _shaded)
        ..anchor = Anchor.topRight
        ..position = size - Vector2.all(300),
    );

    add(
      TextComponent('center', textRenderer: _tiny)
        ..anchor = Anchor.center
        ..position.setFrom(size / 2),
    );

    add(
      TextComponent('bottomRight', textRenderer: _tiny)
        ..anchor = Anchor.bottomRight
        ..position.setFrom(size),
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
