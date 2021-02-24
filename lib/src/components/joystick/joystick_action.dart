import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../extensions/offset.dart';
import '../../extensions/vector2.dart';
import '../../gestures.dart';
import '../../sprite.dart';
import 'joystick_component.dart';
import 'joystick_events.dart';
import 'joystick_utils.dart';

enum JoystickActionAlign { TOP_LEFT, BOTTOM_LEFT, TOP_RIGHT, BOTTOM_RIGHT }

class JoystickAction {
  final int actionId;
  final Sprite? sprite;
  final Sprite? spritePressed;
  final Sprite? spriteBackgroundDirection;
  final double size;
  final double sizeFactorBackgroundDirection;
  final EdgeInsets margin;
  final JoystickActionAlign align;
  final bool enableDirection;
  final Color color;
  final double opacityBackground;
  final double opacityKnob;

  bool isPressed = false;
  Rect? _rectAction;
  Rect? _rectBackgroundDirection;
  bool _dragging = false;
  Sprite? _spriteAction;
  late Offset _dragPosition;
  final Paint _paintBackground;
  final Paint _paintAction;
  final Paint _paintActionPressed;
  late JoystickController _joystickController;
  final double _sizeBackgroundDirection;
  DragEvent? _currentDragEvent;
  late double _tileSize;

  JoystickAction({
    required this.actionId,
    this.sprite,
    this.spritePressed,
    this.spriteBackgroundDirection,
    this.enableDirection = false,
    this.size = 50,
    this.sizeFactorBackgroundDirection = 1.5,
    this.margin = EdgeInsets.zero,
    this.color = Colors.blueGrey,
    this.align = JoystickActionAlign.BOTTOM_RIGHT,
    this.opacityBackground = 0.5,
    this.opacityKnob = 0.8,
  })  : _spriteAction = sprite,
        _sizeBackgroundDirection = sizeFactorBackgroundDirection * size,
        _paintBackground = Paint()
          ..color = color.withOpacity(opacityBackground)
          ..style = PaintingStyle.fill,
        _paintAction = Paint()
          ..color = color.withOpacity(opacityKnob)
          ..style = PaintingStyle.fill,
        _paintActionPressed = Paint()
          ..color = color.withOpacity(opacityBackground)
          ..style = PaintingStyle.fill {
    _tileSize = _sizeBackgroundDirection / 2;
  }

  void initialize(Vector2 _screenSize, JoystickController joystickController) {
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
        dy = _screenSize.y - (margin.bottom + radius);
        break;
      case JoystickActionAlign.TOP_RIGHT:
        dx = _screenSize.x - (margin.right + radius);
        dy = margin.top + radius;
        break;
      case JoystickActionAlign.BOTTOM_RIGHT:
        dx = _screenSize.x - (margin.right + radius);
        dy = _screenSize.y - (margin.bottom + radius);
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
    _dragPosition = _rectAction!.center;
  }

  void render(Canvas c) {
    if (_dragging && enableDirection) {
      JoystickUtils.renderControl(
        c,
        spriteBackgroundDirection,
        _rectBackgroundDirection,
        _paintBackground,
      );
    }

    final actionPaint = isPressed ? _paintActionPressed : _paintAction;
    JoystickUtils.renderControl(c, _spriteAction, _rectAction, actionPaint);
  }

  void update(double dt) {
    if (_rectBackgroundDirection != null && _dragging) {
      final double _radAngle = atan2(
        _dragPosition.dy - _rectBackgroundDirection!.center.dy,
        _dragPosition.dx - _rectBackgroundDirection!.center.dx,
      );

      // Distance between the center of joystick background & drag position
      final centerPosition = _rectBackgroundDirection!.center.toVector2();
      final dragPosition = _dragPosition.toVector2();
      double dist = centerPosition.distanceTo(dragPosition);

      // The maximum distance for the knob position to the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      dist = min(dist, _tileSize);

      // Calculate the knob position
      final double nextX = dist * cos(_radAngle);
      final double nextY = dist * sin(_radAngle);
      final Offset nextPoint = Offset(nextX, nextY);

      if (_rectAction != null) {
        final diff =
            _rectBackgroundDirection!.center + nextPoint - _rectAction!.center;
        _rectAction = _rectAction!.shift(diff);
      }

      final double _intensity = dist / _tileSize;

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
        final Offset diff = _dragPosition - _rectAction!.center;
        _rectAction = _rectAction!.shift(diff);
      }
    }
  }

  void onReceiveDrag(DragEvent event) {
    if (_dragging || !(_rectAction?.contains(event.initialPosition) ?? false)) {
      return;
    }

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
    tapDown();
    _currentDragEvent = event;
    _currentDragEvent!
      ..onUpdate = onPanUpdate
      ..onEnd = onPanEnd
      ..onCancel = onPanCancel;
  }

  void tapDown() {
    isPressed = true;
    if (spritePressed != null) {
      _spriteAction = spritePressed;
    }
  }

  void tapUp() {
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
    _dragPosition = _rectBackgroundDirection!.center;
    _joystickController.joystickAction(
      JoystickActionEvent(
        id: actionId,
        event: ActionEvent.UP,
      ),
    );
    tapUp();
  }

  void onPanCancel() {
    _currentDragEvent = null;
    _dragging = false;
    _dragPosition = _rectBackgroundDirection!.center;
    _joystickController.joystickAction(
      JoystickActionEvent(
        id: actionId,
        event: ActionEvent.CANCEL,
      ),
    );
    tapUp();
  }
}
