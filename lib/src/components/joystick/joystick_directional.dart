import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart'
    show EdgeInsets, DragUpdateDetails, DragEndDetails;

import '../../../components.dart';
import '../../../extensions.dart';
import 'joystick_component.dart';
import 'joystick_element.dart';
import 'joystick_events.dart';

class JoystickDirectional extends BaseComponent with Draggable, HasGameRef {
  final double size;
  final bool isFixed;
  final EdgeInsets margin;

  JoystickElement background;
  JoystickElement knob;

  bool _dragging = false;
  Vector2 _dragPosition;
  double _tileSize;

  JoystickController get joystickController => parent as JoystickController;

  Vector2 _screenSize;

  JoystickDirectional({
    JoystickElement background,
    JoystickElement knob,
    this.isFixed = true,
    this.margin = const EdgeInsets.only(left: 100, bottom: 100),
    this.size = 80,
    Color color = Colors.blueGrey,
    double opacityBackground = 0.5,
    double opacityKnob = 0.8,
  }) {
    this.background = background ??
        JoystickElement.paint(
          Paint()..color = color.withOpacity(opacityBackground),
        );
    this.knob = knob ??
        JoystickElement.paint(
          Paint()..color = color.withOpacity(opacityKnob),
        );

    _tileSize = size / 2;
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

  void initialize(Vector2 screenSize) {
    _screenSize = screenSize;

    final osBackground = Offset(margin.left, _screenSize.y - margin.bottom);
    background.rect = Rect.fromCircle(center: osBackground, radius: size / 2);
    knob.rect = Rect.fromCircle(center: osBackground, radius: size / 4);

    _dragPosition = osBackground.toVector2();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    background.render(canvas);
    knob.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_dragging) {
      // Distance between the center of joystick background & drag position
      final centerPosition = background.center;

      final delta = _dragPosition - centerPosition;
      final radAngle = atan2(delta.y, delta.x);
      final degrees = radAngle * 180 / pi;

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      final dist = min(centerPosition.distanceTo(_dragPosition), _tileSize);

      // Calculation the knob position
      final nextX = dist * cos(radAngle);
      final nextY = dist * sin(radAngle);
      final nextPoint = Vector2(nextX, nextY);

      final diff = centerPosition + nextPoint - knob.center;
      knob.shift(diff);

      final _intensity = dist / _tileSize;

      JoystickMoveDirectional directional;

      if (_intensity == 0) {
        directional = JoystickMoveDirectional.idle;
      } else {
        directional = JoystickDirectionalEvent.calculateDirectionalByDegrees(
          degrees,
        );
      }

      joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
        directional: directional,
        intensity: _intensity,
        radAngle: radAngle,
      ));
    } else {
      final diff = _dragPosition - knob.center;
      knob.shift(diff);
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    final directional = background.rect?.inflate(50.0);
    return directional?.containsPoint(point) == true;
  }

  @override
  bool onDragStart(int pointerId, Vector2 startPosition) {
    _updateDirectionalRect(startPosition);
    if (!_dragging) {
      _dragging = true;
      _dragPosition = startPosition;
      return true;
    }
    return false;
  }

  void _updateDirectionalRect(Vector2 position) {
    if (_screenSize != null &&
        (position.x > _screenSize.x / 2 ||
            position.y < _screenSize.y / 2 ||
            isFixed)) {
      return;
    }

    background.rect = Rect.fromCircle(
      center: position.toOffset(),
      radius: size / 2,
    );

    knob.rect = Rect.fromCircle(
      center: position.toOffset(),
      radius: size / 4,
    );
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateDetails details) {
    if (_dragging) {
      _dragPosition = gameRef.convertGlobalToLocalCoordinate(
        details.globalPosition.toVector2(),
      );
      return false;
    }
    return true;
  }

  @override
  bool onDragEnd(int pointerId, DragEndDetails details) {
    _dragging = false;
    _dragPosition = background.center;
    joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
      directional: JoystickMoveDirectional.idle,
    ));
    return true;
  }

  @override
  bool onDragCancel(int pointerId) {
    _dragging = false;
    _dragPosition = background.center;
    joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
      directional: JoystickMoveDirectional.idle,
    ));
    return true;
  }
}
