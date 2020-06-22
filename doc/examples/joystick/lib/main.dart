import 'dart:math';

import 'package:flame/components/joystick/Joystick_action.dart';
import 'package:flame/components/joystick/Joystick_directional.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
}

class MyGame extends BaseGame
    with MultiTouchDragDetector
    implements JoystickListener {
  final _whitePaint = BasicPalette.white.paint;
  final _bluePaint = Paint()..color = const Color(0xFF0000FF);
  final _greenPaint = Paint()..color = const Color(0xFF00FF00);
  final double speed = 159;
  double currentSpeed = 0;
  double _radAngle;
  bool _move = false;
  Paint _paint;

  Rect _rect;

  final joystick = JoystickComponent(
    directional: JoystickDirectional(),
    actions: [
      JoystickAction(
        actionId: 1,
        size: 50,
        margin: const EdgeInsets.all(50),
        color: const Color(0xFF0000FF),
      ),
      JoystickAction(
        actionId: 2,
        size: 50,
        color: const Color(0xFF00FF00),
        margin: const EdgeInsets.only(
          right: 50,
          bottom: 120,
        ),
      ),
      JoystickAction(
        actionId: 3,
        size: 50,
        margin: const EdgeInsets.only(bottom: 50, right: 120),
        enableDirection: true,
      ),
    ],
  );

  MyGame() {
    _paint = _whitePaint;
    joystick.addObserver(this);
    add(joystick);
  }

  @override
  void update(double dt) {
    if (_move) {
      moveFromAngle(dt);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (_rect != null) {
      canvas.save();
      canvas.translate(_rect.center.dx, _rect.center.dy);
      canvas.rotate(_radAngle == 0.0 ? 0.0 : _radAngle + (pi / 2));
      canvas.translate(-_rect.center.dx, -_rect.center.dy);
      canvas.drawRect(_rect, _paint);
      canvas.restore();
    }
    super.render(canvas);
  }

  @override
  void onReceiveDrag(DragEvent drag) {
    joystick.onReceiveDrag(drag);
    super.onReceiveDrag(drag);
  }

  @override
  void resize(Size size) {
    _rect = Rect.fromLTWH(
      (size.width / 2) - 25,
      (size.height / 2) - 25,
      50,
      50,
    );
    super.resize(size);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) {
      if (event.id == 1) {
        _paint = _paint == _whitePaint ? _bluePaint : _whitePaint;
      }
      if (event.id == 2) {
        _paint = _paint == _whitePaint ? _greenPaint : _whitePaint;
      }
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _move = event.directional != JoystickMoveDirectional.IDLE;
    if (_move) {
      _radAngle = event.radAngle;
      currentSpeed = speed * event.intensity;
    }
  }

  void moveFromAngle(double dtUpdate) {
    final double nextX = (currentSpeed * dtUpdate) * cos(_radAngle);
    final double nextY = (currentSpeed * dtUpdate) * sin(_radAngle);
    final Offset nextPoint = Offset(nextX, nextY);

    final Offset diffBase = Offset(
          _rect.center.dx + nextPoint.dx,
          _rect.center.dy + nextPoint.dy,
        ) -
        _rect.center;

    final Rect newPosition = _rect.shift(diffBase);

    _rect = newPosition;
  }
}
