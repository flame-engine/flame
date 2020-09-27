import 'package:flutter/gestures.dart';

import './game/game.dart';

// Multi touch detector
mixin MultiTouchTapDetector on Game {
  void onTap(int pointerId) {}
  void onTapCancel(int pointerId) {}
  void onTapDown(int pointerId, TapDownDetails details) {}
  void onTapUp(int pointerId, TapUpDetails details) {}
}

class DragEvent extends Drag {
  Offset initialPosition;

  void Function(DragUpdateDetails) onUpdate;
  void Function() onCancel;
  void Function(DragEndDetails) onEnd;

  @override
  void update(details) {
    onUpdate?.call(details);
  }

  @override
  void cancel() {
    onCancel?.call();
  }

  @override
  void end(details) {
    onEnd?.call(details);
  }
}

mixin MultiTouchDragDetector on Game {
  void onReceiveDrag(DragEvent drag) {}
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
