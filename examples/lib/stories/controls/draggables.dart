import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart' show Colors;

// Note: this component does not consider the possibility of multiple
// simultaneous drags with different pointerIds.
class DraggableSquare extends PositionComponent
    with Draggable, HasGameRef<DraggablesGame> {
  @override
  bool debugMode = true;

  DraggableSquare({Vector2? position})
      : super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
        );

  Vector2? dragDeltaPosition;
  bool get isDragging => dragDeltaPosition != null;

  @override
  void update(double dt) {
    super.update(dt);
    debugColor = isDragging ? Colors.greenAccent : Colors.purple;
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    dragDeltaPosition = info.eventPosition.game - position;
    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo event) {
    final dragDeltaPosition = this.dragDeltaPosition;
    if (dragDeltaPosition == null) {
      return false;
    }

    position.setFrom(event.eventPosition.game - dragDeltaPosition);
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

class DraggablesGame extends BaseGame with HasDraggableComponents {
  final double zoom;

  DraggablesGame({required this.zoom});

  @override
  Future<void> onLoad() async {
    camera.zoom = zoom;
    add(DraggableSquare());
    add(DraggableSquare()..y = 350);
  }
}
