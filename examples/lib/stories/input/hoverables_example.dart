import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class HoverablesExample extends FlameGame with HasHoverables, TapDetector {
  static const String description = '''
    This example shows how to use `Hoverable`s.\n\n
    Add more squares by clicking and hover them to change their color.
  ''';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(HoverableSquare(Vector2(200, 500)));
    add(HoverableSquare(Vector2(700, 300)));
  }

  @override
  void onTapDown(TapDownInfo info) {
    add(HoverableSquare(info.eventPosition.game));
  }
}

class HoverableSquare extends PositionComponent with Hoverable {
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _grey = Paint()..color = const Color(0xFFA5A5A5);

  HoverableSquare(Vector2 position)
      : super(position: position, size: Vector2.all(100)) {
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), isHovered ? _grey : _white);
  }
}
