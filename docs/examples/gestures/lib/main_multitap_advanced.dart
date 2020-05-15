import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
}

/// Includes an example mixing two advanced detectors
class MyGame extends Game with MultiTouchTapDetector, MultiTouchDragDetector {
  final _whitePaint = BasicPalette.white.paint;

  Paint _paint;

  final Map<int, Rect> _taps = {};

  Offset _start;
  Offset _end;
  Rect _panRect;

  MyGame() {
    _paint = _whitePaint;
  }

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
  void onReceiveDrag(DragEvent event) {
    onPanStart(event.initialPosition);

    event
      ..onUpdate = onPanUpdate
      ..onEnd = onPanEnd
      ..onCancel = onPanCancel;
  }

  void onPanCancel() {
    _end = null;
    _start = null;
    _panRect = null;
  }

  void onPanStart(Offset position) {
    _end = null;
    _start = position;
  }

  void onPanUpdate(details) {
    _end = details.localPosition;
  }

  void onPanEnd(details) {
    _panRect = Rect.fromLTRB(
      _start.dx,
      _start.dy,
      _end.dx,
      _end.dy,
    );
  }

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    _taps.values.forEach((rect) {
      canvas.drawRect(rect, _paint);
    });

    if (_panRect != null) {
      canvas.drawRect(_panRect, _paint);
    }
  }
}
