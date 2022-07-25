import 'package:flame/game.dart';
import 'package:flame/src/components/mixins/cursor_handler.dart';
import 'package:flame/src/gestures/detectors.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/material.dart';

mixin HasCursorHandlerComponents on FlameGame implements MouseMovementDetector {
  @override
  @mustCallSuper
  void onMouseMove(PointerHoverInfo info) {
    propagateToChildren<CursorHandler>(
      (CursorHandler child) => child.onMouseMove(info),
    );
  }
}
