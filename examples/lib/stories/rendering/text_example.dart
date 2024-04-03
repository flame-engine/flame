import 'dart:async';

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
    addAll(
      [
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
        TextComponent(
          text: 'Scroll me when finished:',
          position: Vector2(size.x / 2, size.y / 2 + 100),
          anchor: Anchor.bottomCenter,
        ),
        MyScrollTextBox(
          'In a bustling city, a small team of developers set out to create '
          'a mobile game using the Flame engine for Flutter. Their goal was '
          'simple: to create an engaging, easy-to-play game that could reach '
          'a wide audience on both iOS and Android platforms. '
          'After weeks of brainstorming, they decided on a concept: '
          'a fast-paced, endless runner game set in a whimsical, '
          'ever-changing world. They named it "Swift Dash." '
          "Using Flutter's versatility and the Flame engine's "
          'capabilities, the team crafted a game with vibrant graphics, '
          'smooth animations, and responsive controls. '
          'The game featured a character dashing through various landscapes, '
          'dodging obstacles, and collecting points. '
          'As they launched "Swift Dash," the team was anxious but hopeful. '
          'To their delight, the game was well-received. Players loved its '
          'simplicity and charm, and the game quickly gained popularity.',
          size: Vector2(200, 150),
          position: Vector2(size.x / 2, size.y / 2 + 100),
          anchor: Anchor.topCenter,
          boxConfig: const TextBoxConfig(
            timePerChar: 0.005,
            margins: EdgeInsets.fromLTRB(10, 10, 10, 10),
          ),
        ),
      ],
    );
  }
}

final _regularTextStyle = TextStyle(
  fontSize: 18,
  color: BasicPalette.white.color,
);
final _regular = TextPaint(
  style: _regularTextStyle,
);
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
  late Paint paint;
  late Rect bgRect;

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
  Future<void> onLoad() {
    paint = Paint();
    bgRect = Rect.fromLTWH(0, 0, width, height);
    size.addListener(() {
      bgRect = Rect.fromLTWH(0, 0, width, height);
    });

    paint.color = Colors.white10;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(bgRect, paint);
    super.render(canvas);
  }
}

class MyScrollTextBox extends ScrollTextBoxComponent {
  late Paint paint;
  late Rect backgroundRect;

  MyScrollTextBox(
    String text, {
    required super.size,
    super.boxConfig,
    super.position,
    super.anchor,
  }) : super(text: text, textRenderer: _box);

  @override
  FutureOr<void> onLoad() {
    paint = Paint();
    backgroundRect = Rect.fromLTWH(0, 0, width, height);

    paint.color = Colors.white10;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(backgroundRect, paint);
    super.render(canvas);
  }
}
