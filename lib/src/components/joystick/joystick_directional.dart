import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart'
    show EdgeInsets, DragUpdateDetails, DragEndDetails;

import '../../../components.dart';
import '../../../extensions.dart';
import '../../sprite.dart';
import 'joystick_component.dart';
import 'joystick_events.dart';
import 'joystick_utils.dart';

class JoystickDirectional extends BaseComponent with Draggable, HasGameRef {
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

  JoystickController get joystickController => parent as JoystickController;

  Vector2 _screenSize;

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
    _backgroundRect = Rect.fromCircle(center: osBackground, radius: size / 2);

    _knobRect = Rect.fromCircle(
      center: _backgroundRect.center,
      radius: size / 4,
    );

    _dragPosition = _knobRect.center.toVector2();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
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

  @override
  void update(double t) {
    super.update(t);
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

      joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
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

  @override
  bool containsPoint(Vector2 point) {
    final directional = _backgroundRect?.inflate(50.0);
    return directional?.containsVector2(point) == true;
  }

  @override
  bool onDragStarted(int pointerId, Vector2 startPosition) {
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

    _backgroundRect = Rect.fromCircle(
      center: position.toOffset(),
      radius: size / 2,
    );

    _knobRect = Rect.fromCircle(
      center: _backgroundRect.center,
      radius: size / 4,
    );
  }

  @override
  bool onDragUpdated(int pointerId, DragUpdateDetails details) {
    if (_dragging) {
      _dragPosition = gameRef.convertGlobalToLocalCoordinate(
        details.globalPosition.toVector2(),
      );
      return false;
    }
    return true;
  }

  @override
  bool onDragEnded(int pointerId, DragEndDetails details) {
    _dragging = false;
    _dragPosition = _backgroundRect.center.toVector2();
    joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
      directional: JoystickMoveDirectional.IDLE,
      intensity: 0.0,
      radAngle: 0.0,
    ));
    return true;
  }

  @override
  bool onDragCanceled(int pointerId) {
    _dragging = false;
    _dragPosition = _backgroundRect.center.toVector2();
    joystickController.joystickChangeDirectional(JoystickDirectionalEvent(
      directional: JoystickMoveDirectional.IDLE,
      intensity: 0.0,
      radAngle: 0.0,
    ));
    return true;
  }
}
