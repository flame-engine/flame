import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class TextExample extends FlameGame {
  static const String description = '''
    In this example we show different ways of rendering text.
  ''';

  @override
  Future<void> onLoad() async {
    addAll([
      TextComponent(text: 'Hello, Flame', textRenderer: _regular)
        ..anchor = Anchor.topCenter
        ..x = size.x / 2
        ..y = 32.0,
      TextComponent(text: 'Text with shade', textRenderer: _shaded)
        ..anchor = Anchor.topRight
        ..position = size - Vector2.all(100),
      TextComponent(text: 'center', textRenderer: _tiny)
        ..anchor = Anchor.center
        ..position.setFrom(size / 2),
      TextComponent(text: 'bottomRight', textRenderer: _tiny)
        ..anchor = Anchor.bottomRight
        ..position.setFrom(size),
      MyTextBox(
        '"This is our world now. The world of the electron and the switch; '
        'the beauty of the baud. We exist without nationality, skin color, '
        'or religious bias. You wage wars, murder, cheat, lie to us and try '
        "to make us believe it's for our own good, yet we're the "
        'criminals. Yes, I am a criminal. My crime is that of curiosity."',
      )
        ..anchor = Anchor.bottomLeft
        ..y = size.y,
      MyTextBox(
        'Let A be a finitely generated torsion-free abelian group. Then '
        'A is free.',
        align: Anchor.center,
        size: Vector2(300, 200),
        timePerChar: 0,
        margins: 10,
      )..position = Vector2(10, 50),
      MyTextBox(
        'Let A be a torsion abelian group. Then A is the direct sum of its '
        'subgroups A(p) for all primes p such that A(p) ≠ 0.',
        align: Anchor.bottomRight,
        size: Vector2(300, 200),
        timePerChar: 0,
        margins: 10,
      )..position = Vector2(10, 260),
    ]);
  }
}

final _regularTextStyle =
    TextStyle(fontSize: 18, color: BasicPalette.white.color);
final _regular = TextPaint(style: _regularTextStyle);
final _tiny = TextPaint(style: _regularTextStyle.copyWith(fontSize: 14.0));
final _box = _regular.copyWith(
  (style) => style.copyWith(
    color: Colors.lightGreenAccent,
    fontFamily: 'monospace',
    letterSpacing: 2.0,
  ),
);
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

class MyTextBox extends TextBoxComponent {
  MyTextBox(
    String text, {
    super.align,
    super.size,
    double? timePerChar,
    double? margins,
  }) : super(
          text: text,
          textRenderer: _box,
          boxConfig: TextBoxConfig(
            maxWidth: 400,
            timePerChar: timePerChar ?? 0.05,
            growingBox: true,
            margins: EdgeInsets.all(margins ?? 25),
          ),
        );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, Paint()..color = Colors.white10);
    super.render(canvas);
  }
}
