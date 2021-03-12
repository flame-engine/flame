import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

/// Includes an example including advanced detectors
class MultitapGame extends BaseGame with MultiTouchTapDetector {
  static final _whitePaint = BasicPalette.white.paint;
  static final _size = Vector2.all(50);

  final Map<int, Rect> _taps = {};

  @override
  void onTapDown(int pointerId, TapDownDetails details) {
    _taps[pointerId] =
        details.globalPosition.toVector2().toPositionedRect(_size);
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
  void render(Canvas canvas) {
    super.render(canvas);
    _taps.values.forEach((rect) {
      canvas.drawRect(rect, _whitePaint);
    });
  }
}
