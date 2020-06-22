import 'dart:math';

import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum JoystickActionAlign { TOP_LEFT, BOTTOM_LEFT, TOP_RIGHT, BOTTOM_RIGHT }

class JoystickAction {
  final int actionId;
  final Sprite sprite;
  final Sprite spritePressed;
  final Sprite spriteBackgroundDirection;
  final double size;
  final double sizeFactorBackgroundDirection;
  final EdgeInsets margin;
  final JoystickActionAlign align;
  final bool enableDirection;
  final Color color;

  bool isPressed = false;
  Rect _rectAction;
  Rect _rectBackgroundDirection;
  bool _dragging = false;
  Sprite _spriteAction;
  Offset _dragPosition;
  Paint _paintBackground;
  Paint _paintAction;
  Paint _paintActionPressed;
  JoystickController _joystickController;
  double _sizeBackgroundDirection;
  DragEvent _currentDragEvent;

  JoystickAction({
    @required this.actionId,
    this.sprite,
    this.spritePressed,
    this.spriteBackgroundDirection,
    this.enableDirection = false,
    this.size = 50,
    this.sizeFactorBackgroundDirection = 1.5,
    this.margin = EdgeInsets.zero,
    this.color = Colors.blueGrey,
    this.align = JoystickActionAlign.BOTTOM_RIGHT,
  }) {
    _spriteAction = sprite;
    _sizeBackgroundDirection = sizeFactorBackgroundDirection * size;
  }

  void initialize(Size _screenSize, JoystickController joystickController) {
    _joystickController = joystickController;
    final double radius = size / 2;
    double dx = 0, dy = 0;
    switch (align) {
      case JoystickActionAlign.TOP_LEFT:
        dx = margin.left + radius;
        dy = margin.top + radius;
        break;
      case JoystickActionAlign.BOTTOM_LEFT:
        dx = margin.left + radius;
        dy = _screenSize.height - (margin.bottom + radius);
        break;
      case JoystickActionAlign.TOP_RIGHT:
        dx = _screenSize.width - (margin.right + radius);
        dy = margin.top + radius;
        break;
      case JoystickActionAlign.BOTTOM_RIGHT:
        dx = _screenSize.width - (margin.right + radius);
        dy = _screenSize.height - (margin.bottom + radius);
        break;
    }
    _rectAction = Rect.fromCircle(
      center: Offset(dx, dy),
      radius: radius,
    );
    _rectBackgroundDirection = Rect.fromCircle(
      center: Offset(dx, dy),
      radius: _sizeBackgroundDirection / 2,
    );

    if (spriteBackgroundDirection == null)
      _paintBackground = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.fill;

    if (sprite == null)
      _paintAction = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill;

    if (spritePressed == null)
      _paintActionPressed = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.fill;

    _dragPosition = _rectAction.center;
  }

  void render(Canvas c) {
    if (_rectBackgroundDirection != null && _dragging && enableDirection) {
      if (spriteBackgroundDirection == null) {
        final double radiusBackground = _rectBackgroundDirection.width / 2;
        c.drawCircle(
          Offset(
            _rectBackgroundDirection.left + radiusBackground,
            _rectBackgroundDirection.top + radiusBackground,
          ),
          radiusBackground,
          _paintBackground,
        );
      } else {
        spriteBackgroundDirection.renderRect(c, _rectBackgroundDirection);
      }
    }

    if (_spriteAction != null) {
      if (_rectAction != null) {
        _spriteAction.renderRect(c, _rectAction);
      }
    } else {
      final double radiusAction = _rectAction.width / 2;
      c.drawCircle(
        Offset(
          _rectAction.left + radiusAction,
          _rectAction.top + radiusAction,
        ),
        radiusAction,
        isPressed ? _paintActionPressed : _paintAction,
      );
    }
  }

  void update(double dt) {
    if (_dragging) {
      final double _radAngle = atan2(
        _dragPosition.dy - _rectBackgroundDirection.center.dy,
        _dragPosition.dx - _rectBackgroundDirection.center.dx,
      );

      // Distance between the center of joystick background & drag position
      final Point centerPoint = Point(
        _rectBackgroundDirection.center.dx,
        _rectBackgroundDirection.center.dy,
      );
      double dist =
          centerPoint.distanceTo(Point(_dragPosition.dx, _dragPosition.dy));

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      dist = dist < (_sizeBackgroundDirection / 3)
          ? dist
          : (_sizeBackgroundDirection / 3);

      // Calculation the knob position
      final double nextX = dist * cos(_radAngle);
      final double nextY = dist * sin(_radAngle);
      final Offset nextPoint = Offset(nextX, nextY);

      final Offset diff = Offset(
            _rectBackgroundDirection.center.dx + nextPoint.dx,
            _rectBackgroundDirection.center.dy + nextPoint.dy,
          ) -
          _rectAction.center;
      _rectAction = _rectAction.shift(diff);

      final double _intensity = dist / (_sizeBackgroundDirection / 3);

      _joystickController.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.MOVE,
          intensity: _intensity,
          radAngle: _radAngle,
        ),
      );
    } else {
      if (_rectAction != null) {
        final Offset diff = _dragPosition - _rectAction.center;
        _rectAction = _rectAction.shift(diff);
      }
    }
  }

  void onReceiveDrag(DragEvent event) {
    if (!_dragging && (_rectAction?.contains(event.initialPosition) ?? false)) {
      if (enableDirection) {
        _dragPosition = event.initialPosition;
        _dragging = true;
      }
      _joystickController.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.DOWN,
        ),
      );
      pressed();
      _currentDragEvent = event;
      _currentDragEvent
        ..onUpdate = onPanUpdate
        ..onEnd = onPanEnd
        ..onCancel = onPanCancel;
    }
  }

  void pressed() {
    isPressed = true;
    if (spritePressed != null) {
      _spriteAction = spritePressed;
    }
  }

  void unPressed() {
    isPressed = false;
    _spriteAction = sprite;
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_dragging) {
      _dragPosition = details.localPosition;
    }
  }

  void onPanEnd(DragEndDetails p1) {
    _currentDragEvent = null;
    _dragging = false;
    _dragPosition = _rectBackgroundDirection.center;
    _joystickController.joystickAction(
      JoystickActionEvent(
        id: actionId,
        event: ActionEvent.UP,
      ),
    );
    unPressed();
  }

  void onPanCancel() {
    _currentDragEvent = null;
    _dragging = false;
    _dragPosition = _rectBackgroundDirection.center;
    _joystickController.joystickAction(
      JoystickActionEvent(
        id: actionId,
        event: ActionEvent.CANCEL,
      ),
    );
    unPressed();
  }
}
