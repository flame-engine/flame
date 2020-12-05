import 'dart:math';

import 'package:flutter/material.dart';

import '../../extensions/offset.dart';
import '../../extensions/vector2.dart';
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
  Paint _paintBackground;
  Rect _backgroundRect;

  Sprite _knobSprite;
  Paint _paintKnob;
  Rect _knobRect;

  bool _dragging = false;
  Offset _dragPosition;
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
      _paintBackground = Paint()
        ..color = color.withOpacity(opacityBackground)
        ..style = PaintingStyle.fill;
    }
    if (spriteKnobDirectional != null) {
      _knobSprite = spriteKnobDirectional;
    } else {
      _paintKnob = Paint()
        ..color = color.withOpacity(opacityKnob)
        ..style = PaintingStyle.fill;
    }

    _tileSize = size / 2;
  }

  void initialize(Vector2 screenSize, JoystickController joystickController) {
    _screenSize = _screenSize;
    _joystickController = joystickController;

    final osBackground = Offset(margin.left, _screenSize.y - margin.bottom);
    _backgroundRect = Rect.fromCircle(center: osBackground, radius: size / 2);

    final osKnob = _backgroundRect.center;
    _knobRect = Rect.fromCircle(center: osKnob, radius: size / 4);

    _dragPosition = _knobRect.center;
  }

  void render(Canvas canvas) {
    JoystickUtils.renderControl(
      canvas,
      _backgroundSprite,
      _backgroundRect,
      _paintBackground,
    );

    JoystickUtils.renderControl(
      canvas,
      _knobSprite,
      _knobRect,
      _paintKnob,
    );
  }

  void update(double t) {
    if (_dragging) {
      final double _radAngle = atan2(
        _dragPosition.dy - _backgroundRect.center.dy,
        _dragPosition.dx - _backgroundRect.center.dx,
      );

      final degrees = _radAngle * 180 / pi;

      // Distance between the center of joystick background & drag position
      final centerPosition = _backgroundRect.center.toVector2();
      final dragPosition = _dragPosition.toVector2();

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      final dist = min(centerPosition.distanceTo(dragPosition), _tileSize);

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
        final Offset diff = _dragPosition - _knobRect.center;
        _knobRect = _knobRect.shift(diff);
      }
    }
  }

  void onReceiveDrag(DragEvent event) {
    _updateDirectionalRect(event.initialPosition);

    final directional = _backgroundRect.inflate(50.0);
    if (!_dragging && directional.contains(event.initialPosition)) {
      _dragging = true;
      _dragPosition = event.initialPosition;
      _currentDragEvent = event;
      _currentDragEvent
        ..onUpdate = onPanUpdate
        ..onEnd = onPanEnd
        ..onCancel = onPanCancel;
    }
  }

  void _updateDirectionalRect(Offset position) {
    if (_screenSize != null &&
        (position.dx > _screenSize.x / 2 ||
            position.dy < _screenSize.y / 2 ||
            isFixed)) {
      return;
    }

    _backgroundRect = Rect.fromCircle(center: position, radius: size / 2);

    final osKnob = _backgroundRect.center;
    _knobRect = Rect.fromCircle(center: osKnob, radius: size / 4);
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_dragging) {
      _dragPosition = details.localPosition;
    }
  }

  void onPanEnd(DragEndDetails p1) {
    _dragging = false;
    _dragPosition = _backgroundRect.center;
    _joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
      directional: JoystickMoveDirectional.IDLE,
      intensity: 0.0,
      radAngle: 0.0,
    ));
    _currentDragEvent = null;
  }

  void onPanCancel() {
    _dragging = false;
    _dragPosition = _backgroundRect.center;
    _joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
      directional: JoystickMoveDirectional.IDLE,
      intensity: 0.0,
      radAngle: 0.0,
    ));
    _currentDragEvent = null;
  }
}
