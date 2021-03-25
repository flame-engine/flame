import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/joystick.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

final _whitePaint = BasicPalette.white.paint;
final _bluePaint = Paint()..color = const Color(0xFF0000FF);
final _greenPaint = Paint()..color = const Color(0xFF00FF00);

class JoystickPlayer extends Component implements JoystickListener {
  static const speed = 32.0;
  static final Vector2 size = Vector2.all(50.0);

  double currentSpeed = 0;
  double angle = 0;
  bool move = false;
  Paint paint;
  late Rect rect;

  JoystickPlayer() : paint = _whitePaint;

  @override
  void render(Canvas canvas) {
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(angle == 0.0 ? 0.0 : angle + (pi / 2));
    canvas.translate(-rect.center.dx, -rect.center.dy);
    canvas.drawRect(rect, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (move) {
      moveFromAngle(dt);
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    final offset = (gameSize - size) / 2;
    rect = offset & size;
    super.onGameResize(gameSize);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.down) {
      if (event.id == 1) {
        paint = paint == _whitePaint ? _bluePaint : _whitePaint;
      }
      if (event.id == 2) {
        paint = paint == _whitePaint ? _greenPaint : _whitePaint;
      }
    } else if (event.event == ActionEvent.move) {
      if (event.id == 3) {
        angle = event.angle;
      }
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    move = event.directional != JoystickMoveDirectional.idle;
    if (move) {
      angle = event.angle;
      currentSpeed = speed * event.intensity;
    }
  }

  void moveFromAngle(double dtUpdate) {
    final next = Vector2(cos(angle), sin(angle)) * (currentSpeed * dtUpdate);
    rect = rect.shift(next.toOffset());
  }
}
