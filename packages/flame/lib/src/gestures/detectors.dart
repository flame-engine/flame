import 'package:flame/src/game/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';

mixin PanDetector on Game {
  void onPanDown(DragDownInfo info) {}
  void onPanStart(DragStartInfo info) {}
  void onPanUpdate(DragUpdateInfo info) {}
  void onPanEnd(DragEndInfo info) {}
  void onPanCancel() {}

  void handlePanDown(DragDownDetails details) {
    onPanDown(DragDownInfo.fromDetails(this, details));
  }

  void handlePanStart(DragStartDetails details) {
    onPanStart(DragStartInfo.fromDetails(this, details));
  }

  void handlePanUpdate(DragUpdateDetails details) {
    onPanUpdate(DragUpdateInfo.fromDetails(this, details));
  }

  void handlePanEnd(DragEndDetails details) {
    onPanEnd(DragEndInfo.fromDetails(details));
  }
}

mixin ScaleDetector on Game {
  void onScaleStart(ScaleStartInfo info) {}
  void onScaleUpdate(ScaleUpdateInfo info) {}
  void onScaleEnd(ScaleEndInfo info) {}

  void handleScaleStart(ScaleStartDetails details) {
    onScaleStart(ScaleStartInfo.fromDetails(this, details));
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
    onScaleUpdate(ScaleUpdateInfo.fromDetails(this, details));
  }

  void handleScaleEnd(ScaleEndDetails details) {
    onScaleEnd(ScaleEndInfo.fromDetails(details));
  }
}

mixin MouseMovementDetector on Game {
  void onMouseMove(PointerHoverInfo info) {}
}

mixin ScrollDetector on Game {
  void onScroll(PointerScrollInfo info) {}
}
