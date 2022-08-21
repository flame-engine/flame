import 'package:flame/src/game/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';

// Basic touch detectors
mixin TapDetector on Game {
  void onTap() {}
  void onTapCancel() {}
  void onTapDown(TapDownInfo info) {}
  void onTapUp(TapUpInfo info) {}

  void handleTapUp(TapUpDetails details) {
    onTapUp(TapUpInfo.fromDetails(this, details));
  }

  void handleTapDown(TapDownDetails details) {
    onTapDown(TapDownInfo.fromDetails(this, details));
  }
}

mixin SecondaryTapDetector on Game {
  void onSecondaryTapDown(TapDownInfo info) {}
  void onSecondaryTapUp(TapUpInfo info) {}
  void onSecondaryTapCancel() {}

  void handleSecondaryTapUp(TapUpDetails details) {
    onSecondaryTapUp(TapUpInfo.fromDetails(this, details));
  }

  void handleSecondaryTapDown(TapDownDetails details) {
    onSecondaryTapDown(TapDownInfo.fromDetails(this, details));
  }
}

mixin TertiaryTapDetector on Game {
  void onTertiaryTapDown(TapDownInfo info) {}
  void onTertiaryTapUp(TapUpInfo info) {}
  void onTertiaryTapCancel() {}

  void handleTertiaryTapUp(TapUpDetails details) {
    onTertiaryTapUp(TapUpInfo.fromDetails(this, details));
  }

  void handleTertiaryTapDown(TapDownDetails details) {
    onTertiaryTapDown(TapDownInfo.fromDetails(this, details));
  }
}

mixin DoubleTapDetector on Game {
  void onDoubleTap() {}
  void onDoubleTapCancel() {}
  void onDoubleTapDown(TapDownInfo info) {}

  void handleDoubleTapDown(TapDownDetails details) {
    onDoubleTapDown(TapDownInfo.fromDetails(this, details));
  }
}

mixin LongPressDetector on Game {
  void onLongPress() {}
  void onLongPressStart(LongPressStartInfo info) {}
  void onLongPressMoveUpdate(LongPressMoveUpdateInfo info) {}
  void onLongPressUp() {}
  void onLongPressEnd(LongPressEndInfo info) {}
  void onLongPressCancel() {}

  void handleLongPressStart(LongPressStartDetails details) {
    onLongPressStart(LongPressStartInfo.fromDetails(this, details));
  }

  void handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    onLongPressMoveUpdate(LongPressMoveUpdateInfo.fromDetails(this, details));
  }

  void handleLongPressEnd(LongPressEndDetails details) {
    onLongPressEnd(LongPressEndInfo.fromDetails(this, details));
  }
}

mixin VerticalDragDetector on Game {
  void onVerticalDragDown(DragDownInfo info) {}
  void onVerticalDragStart(DragStartInfo info) {}
  void onVerticalDragUpdate(DragUpdateInfo info) {}
  void onVerticalDragEnd(DragEndInfo info) {}
  void onVerticalDragCancel() {}

  void handleVerticalDragDown(DragDownDetails details) {
    onVerticalDragDown(DragDownInfo.fromDetails(this, details));
  }

  void handleVerticalDragStart(DragStartDetails details) {
    onVerticalDragStart(DragStartInfo.fromDetails(this, details));
  }

  void handleVerticalDragUpdate(DragUpdateDetails details) {
    onVerticalDragUpdate(DragUpdateInfo.fromDetails(this, details));
  }

  void handleVerticalDragEnd(DragEndDetails details) {
    onVerticalDragEnd(DragEndInfo.fromDetails(this, details));
  }
}

mixin HorizontalDragDetector on Game {
  void onHorizontalDragDown(DragDownInfo info) {}
  void onHorizontalDragStart(DragStartInfo info) {}
  void onHorizontalDragUpdate(DragUpdateInfo info) {}
  void onHorizontalDragEnd(DragEndInfo info) {}
  void onHorizontalDragCancel() {}

  void handleHorizontalDragDown(DragDownDetails details) {
    onHorizontalDragDown(DragDownInfo.fromDetails(this, details));
  }

  void handleHorizontalDragStart(DragStartDetails details) {
    onHorizontalDragStart(DragStartInfo.fromDetails(this, details));
  }

  void handleHorizontalDragUpdate(DragUpdateDetails details) {
    onHorizontalDragUpdate(DragUpdateInfo.fromDetails(this, details));
  }

  void handleHorizontalDragEnd(DragEndDetails details) {
    onHorizontalDragEnd(DragEndInfo.fromDetails(this, details));
  }
}

mixin ForcePressDetector on Game {
  void onForcePressStart(ForcePressInfo info) {}
  void onForcePressPeak(ForcePressInfo info) {}
  void onForcePressUpdate(ForcePressInfo info) {}
  void onForcePressEnd(ForcePressInfo info) {}

  void handleForcePressStart(ForcePressDetails details) {
    onForcePressStart(ForcePressInfo.fromDetails(this, details));
  }

  void handleForcePressPeak(ForcePressDetails details) {
    onForcePressPeak(ForcePressInfo.fromDetails(this, details));
  }

  void handleForcePressUpdate(ForcePressDetails details) {
    onForcePressUpdate(ForcePressInfo.fromDetails(this, details));
  }

  void handleForcePressEnd(ForcePressDetails details) {
    onForcePressEnd(ForcePressInfo.fromDetails(this, details));
  }
}

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
    onPanEnd(DragEndInfo.fromDetails(this, details));
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
    onScaleEnd(ScaleEndInfo.fromDetails(this, details));
  }
}

mixin MouseMovementDetector on Game {
  void onMouseMove(PointerHoverInfo info) {}
}

mixin ScrollDetector on Game {
  void onScroll(PointerScrollInfo info) {}
}
