import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/joystick.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

final _whitePaint = BasicPalette.white.paint();
final _bluePaint = BasicPalette.blue.paint();
final _greenPaint = BasicPalette.green.paint();

class JoystickPlayer extends PositionComponent implements JoystickListener {
  static const speed = 64.0;

  double currentSpeed = 0;
  bool isMoving = false;
  Paint paint;
  late Rect rect;

  JoystickPlayer()
      : paint = _whitePaint,
        super(
          size: Vector2.all(50.0),
          anchor: Anchor.center,
        ) {
    rect = size.toRect();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(rect, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isMoving) {
      moveFromAngle(dt);
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = gameSize / 2;
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    switch (event.event) {
      case ActionEvent.down:
        switch (event.id) {
          case 1:
            paint = paint == _whitePaint ? _bluePaint : _whitePaint;
            break;
          case 2:
            paint = paint == _whitePaint ? _greenPaint : _whitePaint;
            break;
        }
        break;
      case ActionEvent.move:
        if (event.id == 3) {
          angle = event.angle;
        }
        break;
      default:
      // Do nothing
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    isMoving = event.directional != JoystickMoveDirectional.idle;
    if (isMoving) {
      angle = event.angle;
      currentSpeed = speed * event.intensity;
    }
  }

  void moveFromAngle(double dt) {
    final delta = Vector2(cos(angle), sin(angle)) * (currentSpeed * dt);
    position.add(delta);
  }
}
