import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
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
  bool onDragStart(int pointerId, Vector2 startPosition) {
    dragDeltaPosition = startPosition - position;
    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateDetails details) {
    final dragDeltaPosition = this.dragDeltaPosition;
    if (dragDeltaPosition == null) {
      return false;
    }

    final localCoords = gameRef!.convertGlobalToLocalCoordinate(
      details.globalPosition.toVector2(),
    );
    position = localCoords - dragDeltaPosition;
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndDetails details) {
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
  @override
  Future<void> onLoad() async {
    add(DraggableSquare());
    add(DraggableSquare()..y = 350);
  }
}
