import 'package:flame/src/events/game_mixins/multi_touch_drag_detector.dart';
import 'package:flame/src/game/mixins/has_draggables.dart';
import 'package:flutter/gestures.dart';

/// Interface that must be implemented by a game in order for it to be eligible
/// to receive events from an [ImmediateMultiDragGestureRecognizer].
///
/// Instead of implementing this class directly consider using one of the
/// prebuilt mixins:
///  - [HasDraggables] for a `FlameGame`
///  - [MultiTouchDragDetector] for a custom `Game`
abstract class MultiDragListener {
  void handleDragStart(int pointerId, DragStartDetails details);
  void handleDragUpdate(int pointerId, DragUpdateDetails details);
  void handleDragEnd(int pointerId, DragEndDetails details);
  void handleDragCancel(int pointerId);
}
