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

class JoystickPlayer extends Component implements JoystickListener {
  static const speed = 32.0;
  static final Vector2 size = Vector2.all(50.0);

  double currentSpeed = 0;
  double angle = 0;
  bool _move = false;
  Paint _paint;
  Rect _rect;

  JoystickPlayer() {
    _paint = _whitePaint;
  }

  @override
  void render(Canvas canvas) {
    if (_rect == null) {
      return;
    }
    canvas.translate(_rect.center.dx, _rect.center.dy);
    canvas.rotate(angle == 0.0 ? 0.0 : angle + (pi / 2));
    canvas.translate(-_rect.center.dx, -_rect.center.dy);
    canvas.drawRect(_rect, _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_move) {
      moveFromAngle(dt);
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    final offset = (gameSize - size) / 2;
    _rect = offset & size;
    super.onGameResize(gameSize);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.down) {
      if (event.id == 1) {
        _paint = _paint == _whitePaint ? _bluePaint : _whitePaint;
      }
      if (event.id == 2) {
        _paint = _paint == _whitePaint ? _greenPaint : _whitePaint;
      }
    } else if (event.event == ActionEvent.move) {
      if (event.id == 3) {
        angle = event.angle ?? angle;
      }
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _move = event.directional != JoystickMoveDirectional.idle;
    if (_move) {
      angle = event.angle;
      currentSpeed = speed * event.intensity;
    }
  }

  void moveFromAngle(double dtUpdate) {
    if (_rect == null) {
      return;
    }

    final next = Vector2(cos(angle), sin(angle)) * (currentSpeed * dtUpdate);
    _rect = _rect.shift(next.toOffset());
  }
}
