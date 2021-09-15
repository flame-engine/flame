import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' show Colors;

// Note: this component does not consider the possibility of multiple
// simultaneous drags with different pointerIds.
class DraggableSquare extends PositionComponent with Draggable, HasGameRef {
  @override
  bool debugMode = true;

  DraggableSquare({Vector2? position})
      : super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
        );

  Vector2? dragDeltaPosition;

  @override
  void update(double dt) {
    super.update(dt);
    debugColor = isDragged && parent is DraggablesGame
        ? Colors.greenAccent
        : Colors.purple;
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    dragDeltaPosition = info.eventPosition.game - position;
    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    if (parent is! DraggablesGame) {
      return true;
    }
    final dragDeltaPosition = this.dragDeltaPosition;
    if (dragDeltaPosition == null) {
      return false;
    }

    position.setFrom(info.eventPosition.game - dragDeltaPosition);
    return false;
  }

  @override
  bool onDragEnd(int pointerId, _) {
    dragDeltaPosition = null;
    return false;
  }

  @override
  bool onDragCancel(int pointerId) {
    dragDeltaPosition = null;
    return false;
  }
}

class DraggablesGame extends FlameGame with HasDraggableComponents {
  final double zoom;
  late final DraggableSquare square;

  DraggablesGame({required this.zoom});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.zoom = zoom;
    add(square = DraggableSquare());
    add(DraggableSquare()..y = 350);
  }
}
