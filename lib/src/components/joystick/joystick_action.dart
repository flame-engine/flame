import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart'
    show EdgeInsets, DragUpdateDetails, DragEndDetails;

import '../../../components.dart';
import '../../../game.dart';
import '../../extensions/offset.dart';
import '../../extensions/rect.dart';
import '../../extensions/vector2.dart';
import '../../sprite.dart';
import 'joystick_component.dart';
import 'joystick_events.dart';
import 'joystick_utils.dart';

enum JoystickActionAlign { topLeft, bottomLeft, topRight, bottomRight }

class JoystickAction extends BaseComponent with Draggable, HasGameRef {
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
  late Vector2 _dragPosition;
  final Paint _paintBackground;
  final Paint _paintAction;
  final Paint _paintActionPressed;
  final double _sizeBackgroundDirection;
  late double _tileSize;

  JoystickController get joystickController => parent! as JoystickController;

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
    this.align = JoystickActionAlign.bottomRight,
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
    _rectAction = Rect.fromCircle(
      center: Offset(dx, dy),
      radius: radius,
    );
    _rectBackgroundDirection = Rect.fromCircle(
      center: Offset(dx, dy),
      radius: _sizeBackgroundDirection / 2,
    );
    _dragPosition = _rectAction!.center.toVector2();
  }

  @override
  void render(Canvas c) {
    super.render(c);
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

  @override
  void update(double dt) {
    super.update(dt);
    if (_rectBackgroundDirection != null && _dragging) {
      final diff = _dragPosition - _rectBackgroundDirection!.center.toVector2();
      final radAngle = atan2(diff.y, diff.x);

      // Distance between the center of joystick background & drag position
      final centerPosition = _rectBackgroundDirection!.center.toVector2();
      final unboundDist = centerPosition.distanceTo(_dragPosition);

      // The maximum distance for the knob position to the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      final dist = min(unboundDist, _tileSize);

      // Calculate the knob position
      final nextX = dist * cos(radAngle);
      final nextY = dist * sin(radAngle);
      final nextPoint = Offset(nextX, nextY);

      if (_rectAction != null) {
        final diff =
            _rectBackgroundDirection!.center + nextPoint - _rectAction!.center;
        _rectAction = _rectAction!.shift(diff);
      }

      final _intensity = dist / _tileSize;

      joystickController.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.move,
          intensity: _intensity,
          radAngle: radAngle,
        ),
      );
    } else {
      if (_rectAction != null) {
        final diff = _dragPosition - _rectAction!.center.toVector2();
        _rectAction = _rectAction!.shift(diff.toOffset());
      }
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    return _rectAction?.containsPoint(point) == true;
  }

  @override
  bool onDragStart(int pointerId, Vector2 startPosition) {
    if (_dragging) {
      return true;
    }

    if (enableDirection) {
      _dragPosition = startPosition;
      _dragging = true;
    }
    joystickController.joystickAction(
      JoystickActionEvent(
        id: actionId,
        event: ActionEvent.down,
      ),
    );
    tapDown();
    return false;
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

  @override
  bool onDragUpdate(int pointerId, DragUpdateDetails details) {
    if (_dragging) {
      _dragPosition = gameRef.convertGlobalToLocalCoordinate(
        details.globalPosition.toVector2(),
      );
      return true;
    }
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndDetails p1) {
    _dragging = false;
    _dragPosition = _rectBackgroundDirection!.center.toVector2();
    joystickController.joystickAction(
      JoystickActionEvent(
        id: actionId,
        event: ActionEvent.up,
      ),
    );
    tapUp();
    return true;
  }

  @override
  bool onDragCancel(int pointerId) {
    _dragging = false;
    _dragPosition = _rectBackgroundDirection!.center.toVector2();
    joystickController.joystickAction(
      JoystickActionEvent(
        id: actionId,
        event: ActionEvent.cancel,
      ),
    );
    tapUp();
    return true;
  }
}
