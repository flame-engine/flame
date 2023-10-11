import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class HoverCallbacksExample extends FlameGame with TapCallbacks {
  static const String description = '''
    This example shows how to use `HoverCallbacks`s.\n\n
    Add more squares by clicking and hover them to change their color.
  ''';

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(HoverSquare(Vector2(200, 500)));
    world.add(HoverSquare(Vector2(700, 300)));
  }

  @override
  void onTapDown(TapDownEvent event) {
    world.add(HoverSquare(event.localPosition));
  }
}

class HoverSquare extends PositionComponent with HoverCallbacks {
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _grey = Paint()..color = const Color(0xFFA5A5A5);

  HoverSquare(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(100),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), isHovered ? _grey : _white);
  }
}
