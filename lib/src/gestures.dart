import 'package:flutter/gestures.dart';

import '../extensions.dart';
import 'game/game.dart';

mixin MultiTouchTapDetector on Game {
  void onTap(int pointerId) {}
  void onTapCancel(int pointerId) {}
  void onTapDown(int pointerId, TapDownDetails details) {}
  void onTapUp(int pointerId, TapUpDetails details) {}
  void onLongTapDown(int pointerId, TapDownDetails details) {}
}

mixin MultiTouchDragDetector on Game {
  void onDragStarted(int pointerId, Vector2 startPosition) {}
  void onDragUpdated(int pointerId, DragUpdateDetails details) {}
  void onDragEnded(int pointerId, DragEndDetails details) {}
  void onDragCanceled(int pointerId) {}
}

// Basic touch detectors
mixin TapDetector on Game {
  void onTap() {}
  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}
}

mixin SecondaryTapDetector on Game {
  void onSecondaryTapDown(TapDownDetails details) {}
  void onSecondaryTapUp(TapUpDetails details) {}
  void onSecondaryTapCancel() {}
}

mixin DoubleTapDetector on Game {
  void onDoubleTap() {}
}

mixin LongPressDetector on Game {
  void onLongPress() {}
  void onLongPressStart(LongPressStartDetails details) {}
  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {}
  void onLongPressUp() {}
  void onLongPressEnd(LongPressEndDetails details) {}
}

mixin VerticalDragDetector on Game {
  void onVerticalDragDown(DragDownDetails details) {}
  void onVerticalDragStart(DragStartDetails details) {}
  void onVerticalDragUpdate(DragUpdateDetails details) {}
  void onVerticalDragEnd(DragEndDetails details) {}
  void onVerticalDragCancel() {}
}

mixin HorizontalDragDetector on Game {
  void onHorizontalDragDown(DragDownDetails details) {}
  void onHorizontalDragStart(DragStartDetails details) {}
  void onHorizontalDragUpdate(DragUpdateDetails details) {}
  void onHorizontalDragEnd(DragEndDetails details) {}
  void onHorizontalDragCancel() {}
}

mixin ForcePressDetector on Game {
  void onForcePressStart(ForcePressDetails details) {}
  void onForcePressPeak(ForcePressDetails details) {}
  void onForcePressUpdate(ForcePressDetails details) {}
  void onForcePressEnd(ForcePressDetails details) {}
}

mixin PanDetector on Game {
  void onPanDown(DragDownDetails details) {}
  void onPanStart(DragStartDetails details) {}
  void onPanUpdate(DragUpdateDetails details) {}
  void onPanEnd(DragEndDetails details) {}
  void onPanCancel() {}
}

mixin ScaleDetector on Game {
  void onScaleStart(ScaleStartDetails details) {}
  void onScaleUpdate(ScaleUpdateDetails details) {}
  void onScaleEnd(ScaleEndDetails details) {}
}

mixin MouseMovementDetector on Game {
  void onMouseMove(PointerHoverEvent event) {}
}

mixin ScrollDetector on Game {
  void onScroll(PointerScrollEvent event) {}
}
