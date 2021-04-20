import '../../extensions.dart';
import '../game/game.dart';
import 'events.dart';

mixin MultiTouchTapDetector on Game {
  void onTap(int pointerId) {}
  void onTapCancel(int pointerId) {}
  void onTapDown(int pointerId, TapDownInfo event) {}
  void onTapUp(int pointerId, TapUpInfo event) {}
  void onLongTapDown(int pointerId, TapDownInfo event) {}
}

mixin MultiTouchDragDetector on Game {
  void onDragStart(int pointerId, Vector2 startPosition) {}
  void onDragUpdate(int pointerId, DragUpdateInfo info) {}
  void onDragEnd(int pointerId, DragEndInfo info) {}
  void onDragCancel(int pointerId) {}
}

// Basic touch detectors
mixin TapDetector on Game {
  void onTap() {}
  void onTapCancel() {}
  void onTapDown(TapDownInfo event) {}
  void onTapUp(TapUpInfo event) {}
}

mixin SecondaryTapDetector on Game {
  void onSecondaryTapDown(TapDownInfo event) {}
  void onSecondaryTapUp(TapUpInfo event) {}
  void onSecondaryTapCancel() {}
}

mixin DoubleTapDetector on Game {
  void onDoubleTap() {}
}

mixin LongPressDetector on Game {
  void onLongPress() {}
  void onLongPressStart(LongPressStartInfo event) {}
  void onLongPressMoveUpdate(LongPressMoveUpdateInfo event) {}
  void onLongPressUp() {}
  void onLongPressEnd(LongPressEndInfo event) {}
}

mixin VerticalDragDetector on Game {
  void onVerticalDragDown(DragDownInfo info) {}
  void onVerticalDragStart(DragStartInfo info) {}
  void onVerticalDragUpdate(DragUpdateInfo info) {}
  void onVerticalDragEnd(DragEndInfo info) {}
  void onVerticalDragCancel() {}
}

mixin HorizontalDragDetector on Game {
  void onHorizontalDragDown(DragDownInfo info) {}
  void onHorizontalDragStart(DragStartInfo info) {}
  void onHorizontalDragUpdate(DragUpdateInfo info) {}
  void onHorizontalDragEnd(DragEndInfo info) {}
  void onHorizontalDragCancel() {}
}

mixin ForcePressDetector on Game {
  void onForcePressStart(ForcePressInfo info) {}
  void onForcePressPeak(ForcePressInfo info) {}
  void onForcePressUpdate(ForcePressInfo info) {}
  void onForcePressEnd(ForcePressInfo info) {}
}

mixin PanDetector on Game {
  void onPanDown(DragDownInfo info) {}
  void onPanStart(DragStartInfo info) {}
  void onPanUpdate(DragUpdateInfo info) {}
  void onPanEnd(DragEndInfo info) {}
  void onPanCancel() {}
}

mixin ScaleDetector on Game {
  void onScaleStart(ScaleStartInfo info) {}
  void onScaleUpdate(ScaleUpdateInfo info) {}
  void onScaleEnd(ScaleEndInfo info) {}
}

mixin MouseMovementDetector on Game {
  void onMouseMove(PointerHoverInfo event) {}
}

mixin ScrollDetector on Game {
  void onScroll(PointerScrollInfo event) {}
}
