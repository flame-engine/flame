import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart' show EdgeInsets;

import '../../../components.dart';
import '../../../game.dart';
import '../../extensions/offset.dart';
import '../../extensions/rect.dart';
import '../../extensions/vector2.dart';
import '../../gestures/events.dart';
import 'joystick_component.dart';
import 'joystick_element.dart';
import 'joystick_events.dart';

enum JoystickActionAlign { topLeft, bottomLeft, topRight, bottomRight }

class JoystickAction extends BaseComponent with Draggable, HasGameRef {
  @override
  bool isHud = true;

  final int actionId;
  final double size;
  final double _sizeBackgroundDirection;
  final EdgeInsets margin;
  final JoystickActionAlign align;
  final bool enableDirection;

  bool isPressed = false;
  bool _dragging = false;
  late Vector2 _dragPosition;
  late double _tileSize;

  late JoystickElement backgroundDirection;
  late JoystickElement action;
  late JoystickElement actionPressed;

  JoystickController get joystickController => parent! as JoystickController;

  JoystickAction({
    required this.actionId,
    JoystickElement? backgroundDirection,
    JoystickElement? action,
    JoystickElement? actionPressed,
    this.enableDirection = false,
    this.size = 50,
    this.margin = EdgeInsets.zero,
    this.align = JoystickActionAlign.bottomRight,
    double sizeFactorBackgroundDirection = 1.5,
    Color color = Colors.blueGrey,
    double opacityBackground = 0.5,
    double opacityKnob = 0.8,
  }) : _sizeBackgroundDirection = sizeFactorBackgroundDirection * size {
    this.action = action ??
        JoystickElement.paint(
          Paint()..color = color.withOpacity(opacityKnob),
        );
    this.actionPressed = actionPressed ??
        JoystickElement.paint(
          Paint()..color = color.withOpacity(opacityKnob),
        );
    this.backgroundDirection = backgroundDirection ??
        JoystickElement.paint(
          Paint()..color = color.withOpacity(opacityBackground),
        );

    _tileSize = _sizeBackgroundDirection / 2;
  }

  @override
  Future<void> onLoad() async {
    initialize(gameRef.size);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    initialize(gameSize);
  }

  void initialize(Vector2 _screenSize) {
    final radius = size / 2;
    var dx = 0.0, dy = 0.0;
    switch (align) {
      case JoystickActionAlign.topLeft:
        dx = margin.left + radius;
        dy = margin.top + radius;
        break;
      case JoystickActionAlign.bottomLeft:
        dx = margin.left + radius;
        dy = _screenSize.y - (margin.bottom + radius);
        break;
      case JoystickActionAlign.topRight:
        dx = _screenSize.x - (margin.right + radius);
        dy = margin.top + radius;
        break;
      case JoystickActionAlign.bottomRight:
        dx = _screenSize.x - (margin.right + radius);
        dy = _screenSize.y - (margin.bottom + radius);
        break;
    }
    final center = Offset(dx, dy);
    action.rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );
    actionPressed.rect = action.rect;
    backgroundDirection.rect = Rect.fromCircle(
      center: center,
      radius: _sizeBackgroundDirection / 2,
    );
    _dragPosition = action.center;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (_dragging && enableDirection) {
      backgroundDirection.render(c);
    }

    (isPressed ? actionPressed : action).render(c);
  }

  @override
  void update(double dt) {
    super.update(dt);

    Vector2 diff;
    if (_dragging) {
      // Distance between the center of joystick background & drag position
      final centerPosition = backgroundDirection.center;

      final atanDiff = _dragPosition - centerPosition;
      final angle = atan2(atanDiff.y, atanDiff.x);

      final unboundDist = centerPosition.distanceTo(_dragPosition);

      // The maximum distance for the knob position to the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      final dist = min(unboundDist, _tileSize);

      // Calculate the knob position
      final nextX = cos(angle);
      final nextY = sin(angle);
      final nextPoint = Vector2(nextX, nextY) * dist;

      diff = backgroundDirection.center + nextPoint - action.center;

      final _intensity = dist / _tileSize;

      _sendEvent(ActionEvent.move, intensity: _intensity, angle: angle);
    } else {
      diff = _dragPosition - action.center;
    }

    action.shift(diff);
    actionPressed.rect = action.rect;
  }

  @override
  bool containsPoint(Vector2 point) {
    return action.rect.containsPoint(point);
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    if (_dragging) {
      return true;
    }

    if (enableDirection) {
      _dragPosition = info.eventPosition.widget;
      _dragging = true;
    }
    _sendEvent(ActionEvent.down);
    tapDown();
    return false;
  }

  void tapDown() {
    isPressed = true;
  }

  void tapUp() {
    isPressed = false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    if (_dragging) {
      _dragPosition = info.eventPosition.game;
      return true;
    }
    return false;
  }

  @override
  bool onDragEnd(_, __) {
    return _finishDrag(ActionEvent.up);
  }

  @override
  bool onDragCancel(int pointerId) {
    return _finishDrag(ActionEvent.cancel);
  }

  bool _finishDrag(ActionEvent event) {
    _dragging = false;
    _dragPosition = backgroundDirection.center;
    _sendEvent(event);
    tapUp();
    return true;
  }

  void _sendEvent(ActionEvent event, {double? intensity, double? angle}) {
    joystickController.joystickAction(
      JoystickActionEvent(
        id: actionId,
        event: event,
        intensity: intensity ?? 0.0,
        angle: angle ?? 0.0,
      ),
    );
  }
}
