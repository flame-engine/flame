import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class SecondaryTapCallbacksExample extends FlameGame {
  static const String description = '''
    In this example we show how to listen to both primary (left) and
    secondary (right) tap events using the `TapCallbacks` and
    the `SecondaryTapCallbacks` mixin to any `PositionComponent`.\n\n
    The squares will change color depending on which button was used to tap them.
  ''';

  @override
  Future<void> onLoad() async {
    world.add(TappableSquare()..anchor = Anchor.center);
    world.add(TappableSquare()..y = 350);
  }
}

class TappableSquare extends RectangleComponent
    with TapCallbacks, SecondaryTapCallbacks {
  static final Paint _red = BasicPalette.red.paint();
  static final Paint _blue = BasicPalette.blue.paint();
  static final TextPaint _text = TextPaint(
    style: TextStyle(color: BasicPalette.white.color, fontSize: 24),
  );

  int counter = 0;

  TappableSquare({Vector2? position})
    : super(
        position: position ?? Vector2.all(100),
        size: Vector2.all(100),
        paint: _red,
        anchor: Anchor.center,
      );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _text.render(
      canvas,
      '$counter',
      size / 2,
      anchor: Anchor.center,
    );
  }

  @override
  void onTapDown(_) {
    paint = _red;
    counter++;
  }

  @override
  void onSecondaryTapDown(_) {
    paint = _blue;
    counter++;
  }
}
