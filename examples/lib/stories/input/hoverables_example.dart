import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class HoverablesExample extends FlameGame with HasHoverables, TapDetector {
  static const String description = '''
    This example shows how to use `Hoverables`s.\n\n
    Add more squares by clicking and hover them to change their color.
  ''';

  @override
  Future<void> onLoad() async {
    add(Hoverablesquare(Vector2(200, 500)));
    add(Hoverablesquare(Vector2(700, 300)));
  }

  @override
  void onTapDown(TapDownInfo info) {
    add(Hoverablesquare(info.eventPosition.game));
  }
}

class Hoverablesquare extends PositionComponent with Hoverables {
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _grey = Paint()..color = const Color(0xFFA5A5A5);

  Hoverablesquare(Vector2 position)
      : super(position: position, size: Vector2.all(100)) {
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), isHovered ? _grey : _white);
  }
}
