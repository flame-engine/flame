import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

/// Showcases how to mix two advanced detectors
class MultitapAdvancedGame extends BaseGame
    with MultiTouchTapDetector, MultiTouchDragDetector {
  static final whitePaint = BasicPalette.white.paint;
  static final tapSize = Vector2.all(50);

  final Map<int, Rect> taps = {};

  Vector2? start;
  Vector2? end;
  Rect? panRect;

  @override
  void onTapDown(int pointerId, TapDownDetails details) {
    taps[pointerId] =
        details.globalPosition.toVector2().toPositionedRect(tapSize);
  }

  @override
  void onTapUp(int pointerId, _) {
    taps.remove(pointerId);
  }

  @override
  void onTapCancel(int pointerId) {
    taps.remove(pointerId);
  }

  @override
  void onDragCancel(int pointerId) {
    end = null;
    start = null;
    panRect = null;
  }

  @override
  void onDragStart(int pointerId, Vector2 position) {
    end = null;
    start = position;
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateDetails details) {
    end = details.localPosition.toVector2();
  }

  @override
  void onDragEnd(int pointerId, DragEndDetails details) {
    final start = this.start, end = this.end;
    if (start != null && end != null) {
      panRect = start.toPositionedRect(end - start);
    }
  }

  @override
  void render(Canvas canvas) {
    final panRect = this.panRect;
    super.render(canvas);
    taps.values.forEach((rect) {
      canvas.drawRect(rect, whitePaint);
    });

    if (panRect != null) {
      canvas.drawRect(panRect, whitePaint);
    }
  }
}
