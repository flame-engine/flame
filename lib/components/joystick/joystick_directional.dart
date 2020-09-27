import 'dart:math';

import 'package:flutter/material.dart';

import '../../gestures.dart';
import '../../position.dart';
import '../../sprite.dart';
import 'joystick_component.dart';
import 'joystick_events.dart';

class JoystickDirectional {
  final double size;
  final Sprite spriteBackgroundDirectional;
  final Sprite spriteKnobDirectional;
  final bool isFixed;
  final EdgeInsets margin;
  final Color color;
  final double opacityBackground;
  final double opacityKnob;

  Paint _paintBackground;
  Paint _paintKnob;

  Sprite _backgroundSprite;
  Sprite _knobSprite;

  Rect _backgroundRect;
  Rect _knobRect;

  bool _dragging = false;
  Offset _dragPosition;
  double _tileSize;

  JoystickController _joystickController;

  Size _screenSize;

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

  void initialize(Size _screenSize, JoystickController joystickController) {
    this._screenSize = _screenSize;
    _joystickController = joystickController;
    final Offset osBackground =
        Offset(margin.left, _screenSize.height - margin.bottom);
    _backgroundRect = Rect.fromCircle(center: osBackground, radius: size / 2);

    final Offset osKnob =
        Offset(_backgroundRect.center.dx, _backgroundRect.center.dy);
    _knobRect = Rect.fromCircle(center: osKnob, radius: size / 4);

    _dragPosition = _knobRect.center;
  }

  void render(Canvas canvas) {
    if (_backgroundRect != null) {
      if (_backgroundSprite != null) {
        _backgroundSprite.renderRect(canvas, _backgroundRect);
      } else {
        final double radiusBackground = _backgroundRect.width / 2;
        canvas.drawCircle(
          Offset(_backgroundRect.left + radiusBackground,
              _backgroundRect.top + radiusBackground),
          radiusBackground,
          _paintBackground,
        );
      }
    }

    if (_knobRect != null) {
      if (_knobSprite != null) {
        _knobSprite.renderRect(canvas, _knobRect);
      } else {
        final double radiusKnob = _knobRect.width / 2;
        canvas.drawCircle(
          Offset(_knobRect.left + radiusKnob, _knobRect.top + radiusKnob),
          radiusKnob,
          _paintKnob,
        );
      }
    }
  }

  void update(double t) {
    if (_dragging) {
      final double _radAngle = atan2(
          _dragPosition.dy - _backgroundRect.center.dy,
          _dragPosition.dx - _backgroundRect.center.dx);

      final double degrees = _radAngle * 180 / pi;

      // Distance between the center of joystick background & drag position
      final centerPosition = Position.fromOffset(_backgroundRect.center);
      final dragPosition = Position.fromOffset(_dragPosition);
      double dist = centerPosition.distance(dragPosition);

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      dist = min(dist, _tileSize);

      // Calculation the knob position
      final double nextX = dist * cos(_radAngle);
      final double nextY = dist * sin(_radAngle);
      final Offset nextPoint = Offset(nextX, nextY);

      final Offset diff = Offset(
            _backgroundRect.center.dx + nextPoint.dx,
            _backgroundRect.center.dy + nextPoint.dy,
          ) -
          _knobRect.center;
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

    final Rect directional = Rect.fromLTWH(
      _backgroundRect.left - 50,
      _backgroundRect.top - 50,
      _backgroundRect.width + 100,
      _backgroundRect.height + 100,
    );

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
        (position.dx > _screenSize.width / 2 ||
            position.dy < _screenSize.height / 2 ||
            isFixed)) {
      return;
    }

    _backgroundRect = Rect.fromCircle(center: position, radius: size / 2);

    final Offset osKnob = Offset(
      _backgroundRect.center.dx,
      _backgroundRect.center.dy,
    );
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
