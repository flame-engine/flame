import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/joystick.dart';
import 'package:flame/palette.dart';

class Player extends Component implements JoystickListener {
  final _whitePaint = BasicPalette.white.paint;
  final _bluePaint = Paint()..color = const Color(0xFF0000FF);
  final _greenPaint = Paint()..color = const Color(0xFF00FF00);
  final double speed = 159;
  double currentSpeed = 0;
  double radAngle = 0;
  bool _move = false;
  Paint _paint;

  Rect _rect;

  Player() {
    _paint = _whitePaint;
  }

  @override
  void render(Canvas canvas) {
    if (_rect == null) {
      return;
    }
    canvas.save();
    canvas.translate(_rect.center.dx, _rect.center.dy);
    canvas.rotate(radAngle == 0.0 ? 0.0 : radAngle + (pi / 2));
    canvas.translate(-_rect.center.dx, -_rect.center.dy);
    canvas.drawRect(_rect, _paint);
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_move) {
      moveFromAngle(dt);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    _rect = Rect.fromLTWH(
      (size.x / 2) - 25,
      (size.y / 2) - 25,
      50,
      50,
    );
    super.onGameResize(size);
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
      radAngle = event.radAngle;
      currentSpeed = speed * event.intensity;
    }
  }

  void moveFromAngle(double dtUpdate) {
    final double nextX = (currentSpeed * dtUpdate) * cos(radAngle);
    final double nextY = (currentSpeed * dtUpdate) * sin(radAngle);

    if (_rect == null) {
      return;
    }

    final Offset diffBase = Offset(
          _rect.center.dx + nextX,
          _rect.center.dy + nextY,
        ) -
        _rect.center;
    _rect = _rect.shift(diffBase);
  }
}
