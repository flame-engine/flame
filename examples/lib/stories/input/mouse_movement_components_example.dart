import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MouseMovementComponentsExample extends FlameGame
    with HasCursorHandlerComponents {
  static const String description = '''
    This example shows how to handle mouse movement using `CursorHandler` Components.\n\n
    Moving the mouse around the canvas changes the angle of each Component, and causes
    the line drawn on them to face towards the mouse's position.
  ''';

  @override
  Future<void> onLoad() async {
    add(
      CursorFollowerCircle(
        radius: 20.0,
      )..position = size / 2,
    );
    add(
      CursorFollowerCircle(
        radius: 20.0,
      )..position = Vector2(100.0, 100.0),
    );
  }
}

class CursorFollowerCircle extends PositionComponent with CursorHandler {
  final double _radius;

  final Paint _paint;

  CursorFollowerCircle({required double radius})
      : _radius = radius,
        _paint = Paint()..color = const Color(0xFF80C080),
        super(
          size: Vector2.all(2 * radius),
          anchor: Anchor.center,
        );

  @override
  bool onMouseMove(PointerHoverInfo info) {
    final gameMousePositionX = info.eventPosition.game.x;

    final gameMousePositionY = info.eventPosition.game.y;

    angle =
        atan2(gameMousePositionY - position.y, gameMousePositionX - position.x);
    return super.onMouseMove(info);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawCircle(
      Offset(_radius, _radius),
      _radius,
      _paint,
    );
    canvas.drawLine(
      Offset(_radius, _radius),
      Offset(_radius * 3.0, _radius),
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..strokeWidth = 2.0,
    );
  }
}
