import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/gestures.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

/// Includes an example mixing two advanced detectors
class MyGame extends BaseGame
    with MultiTouchTapDetector, MultiTouchDragDetector {
  final _whitePaint = BasicPalette.white.paint;

  final Map<int, Rect> _taps = {};

  Vector2? _start;
  Vector2? _end;
  Rect? _panRect;

  @override
  void onTapDown(int pointerId, TapDownDetails details) {
    _taps[pointerId] = Rect.fromLTWH(
      details.globalPosition.dx,
      details.globalPosition.dy,
      50,
      50,
    );
  }

  @override
  void onTapUp(int pointerId, _) {
    _taps.remove(pointerId);
  }

  @override
  void onTapCancel(int pointerId) {
    _taps.remove(pointerId);
  }

  @override
  void onDragCancel(int pointerId) {
    _end = null;
    _start = null;
    _panRect = null;
  }

  @override
  void onDragStart(int pointerId, Vector2 initialPosition) {
    _end = null;
    _start = initialPosition;
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateDetails details) {
    _end = details.localPosition.toVector2();
  }

  @override
  void onDragEnd(int pointerId, DragEndDetails details) {
    if (_start != null && _end != null) {
      _panRect = Rect.fromLTRB(
        _start!.x,
        _start!.y,
        _end!.x,
        _end!.y,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _taps.values.forEach((rect) {
      canvas.drawRect(rect, _whitePaint);
    });

    if (_panRect != null) {
<<<<<<< HEAD
      canvas.drawRect(_panRect!, _whitePaint);
=======
      canvas.drawRect(_panRect, _whitePaint);
>>>>>>> master
    }
  }
}
