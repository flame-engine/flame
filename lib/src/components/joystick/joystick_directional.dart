import 'dart:math';

import 'package:flutter/material.dart';

import '../../../extensions.dart';
import '../../gestures.dart';
import '../../sprite.dart';
import 'joystick_component.dart';
import 'joystick_events.dart';
import 'joystick_utils.dart';

class JoystickDirectional {
  final double size;
  final Sprite spriteBackgroundDirectional;
  final Sprite spriteKnobDirectional;
  final bool isFixed;
  final EdgeInsets margin;
  final Color color;
  final double opacityBackground;
  final double opacityKnob;

  Sprite _backgroundSprite;
  Paint _backgroundPaint;
  Rect _backgroundRect;

  Sprite _knobSprite;
  Paint _knobPaint;
  Rect _knobRect;

  bool _dragging = false;
  Vector2 _dragPosition;
  double _tileSize;

  JoystickController _joystickController;

  Vector2 _screenSize;

  DragEvent _currentDragEvent;

  JoystickDirectional({
    this.spriteBackgroundDirectional,
    this.spriteKnobDirectional,
    this.isFixed = true,
    this.margin = const EdgeInsets.only(left: 100, bottom: 100),
    this.size = 80,
    this.color = Colors.blueGrey,
    this.opacityBackground = 0.5,
    this.opacityKnob = 0.8,
  }) {
    if (spriteBackgroundDirectional != null) {
      _backgroundSprite = spriteBackgroundDirectional;
    } else {
      _backgroundPaint = Paint()
        ..color = color.withOpacity(opacityBackground)
        ..style = PaintingStyle.fill;
    }
    if (spriteKnobDirectional != null) {
      _knobSprite = spriteKnobDirectional;
    } else {
      _knobPaint = Paint()
        ..color = color.withOpacity(opacityKnob)
        ..style = PaintingStyle.fill;
    }

    _tileSize = size / 2;
  }

  void initialize(Vector2 screenSize, JoystickController joystickController) {
    _screenSize = screenSize;
    _joystickController = joystickController;

    final osBackground = Offset(margin.left, _screenSize.y - margin.bottom);
    _backgroundRect = Rect.fromCircle(center: osBackground, radius: size / 2);

    _knobRect = Rect.fromCircle(
      center: _backgroundRect.center,
      radius: size / 4,
    );

    _dragPosition = _knobRect.center.toVector2();
  }

  void render(Canvas canvas) {
    JoystickUtils.renderControl(
      canvas,
      _backgroundSprite,
      _backgroundRect,
      _backgroundPaint,
    );

    JoystickUtils.renderControl(
      canvas,
      _knobSprite,
      _knobRect,
      _knobPaint,
    );
  }

  void update(double t) {
    if (_dragging) {
      final delta = _dragPosition - _backgroundRect.center.toVector2();
      final double _radAngle = atan2(delta.y, delta.x);

      final degrees = _radAngle * 180 / pi;

      // Distance between the center of joystick background & drag position
      final centerPosition = _backgroundRect.center.toVector2();

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      final dist = min(centerPosition.distanceTo(_dragPosition), _tileSize);

      // Calculation the knob position
      final nextX = dist * cos(_radAngle);
      final nextY = dist * sin(_radAngle);
      final nextPoint = Offset(nextX, nextY);

      final diff = _backgroundRect.center + nextPoint - _knobRect.center;
      _knobRect = _knobRect.shift(diff);

      final double _intensity = dist / _tileSize;

      JoystickMoveDirectional directional;

      if (_intensity == 0) {
        directional = JoystickMoveDirectional.IDLE;
      } else {
        directional = JoystickDirectionalEvent.calculateDirectionalByDegrees(
          degrees,
        );
      }

      _joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
        directional: directional,
        intensity: _intensity,
        radAngle: _radAngle,
      ));
    } else {
      if (_knobRect != null) {
        final diff = _dragPosition - _knobRect.center.toVector2();
        _knobRect = _knobRect.shift(diff.toOffset());
      }
    }
  }

  void onReceiveDrag(DragEvent event) {
    _updateDirectionalRect(event.initialPosition);

    final directional = _backgroundRect.inflate(50.0);
    if (!_dragging && directional.containsVector2(event.initialPosition)) {
      _dragging = true;
      _dragPosition = event.initialPosition;
      _currentDragEvent = event;
      _currentDragEvent
        ..onUpdate = onPanUpdate
        ..onEnd = onPanEnd
        ..onCancel = onPanCancel;
    }
  }

  void _updateDirectionalRect(Vector2 position) {
    if (_screenSize != null &&
        (position.x > _screenSize.x / 2 ||
            position.y < _screenSize.y / 2 ||
            isFixed)) {
      return;
    }

    _backgroundRect = Rect.fromCircle(
      center: position.toOffset(),
      radius: size / 2,
    );

    _knobRect = Rect.fromCircle(
      center: _backgroundRect.center,
      radius: size / 4,
    );
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_dragging) {
      _dragPosition = details.localPosition.toVector2();
    }
  }

  void onPanEnd(DragEndDetails p1) {
    _dragging = false;
    _dragPosition = _backgroundRect.center.toVector2();
    _joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
      directional: JoystickMoveDirectional.IDLE,
      intensity: 0.0,
      radAngle: 0.0,
    ));
    _currentDragEvent = null;
  }

  void onPanCancel() {
    _dragging = false;
    _dragPosition = _backgroundRect.center.toVector2();
    _joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
      directional: JoystickMoveDirectional.IDLE,
      intensity: 0.0,
      radAngle: 0.0,
    ));
    _currentDragEvent = null;
  }
}
