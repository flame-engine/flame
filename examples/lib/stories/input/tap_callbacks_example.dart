import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class TapCallbacksExample extends FlameGame {
  static const String description = '''
    In this example we show the `TapCallbacks` mixin functionality. You can add
    the `TapCallbacks` mixin to any `PositionComponent`.\n\n
    Tap the squares to see them change their angle around their anchor.
  ''';

  @override
  Future<void> onLoad() async {
    world.add(TappableSquare()..anchor = Anchor.center);
    world.add(TappableSquare()..y = 350);
  }
}

class TappableSquare extends PositionComponent with TapCallbacks {
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _grey = Paint()..color = const Color(0xFFA5A5A5);

  bool _beenPressed = false;

  TappableSquare({Vector2? position})
      : super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
        );

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _beenPressed ? _grey : _white);
  }

  @override
  void onTapUp(_) {
    _beenPressed = false;
  }

  @override
  void onTapDown(_) {
    _beenPressed = true;
    angle += 1.0;
  }

  @override
  void onTapCancel(_) {
    _beenPressed = false;
  }
}
