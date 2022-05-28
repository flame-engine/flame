import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' show Colors;

class DraggablesExample extends FlameGame with HasDraggables {
  static const String description = '''
    In this example we show you can use the `Draggable` mixin on
    `PositionComponent`s. Drag around the Embers and see their position
    changing.
  ''';

  final double zoom;
  late final DraggableSquare square;

  DraggablesExample({required this.zoom});

  @override
  Future<void> onLoad() async {
    camera.zoom = zoom;
    add(square = DraggableSquare());
    add(DraggableSquare()..y = 350);
  }
}

// Note: this component does not consider the possibility of multiple
// simultaneous drags with different pointerIds.
class DraggableSquare extends Ember with Draggable {
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
    debugColor = isDragged && parent is DraggablesExample
        ? Colors.greenAccent
        : Colors.purple;
  }

  @override
  bool onDragStart(DragStartInfo info) {
    dragDeltaPosition = info.eventPosition.game - position;
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    if (parent is! DraggablesExample) {
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
  bool onDragEnd(_) {
    dragDeltaPosition = null;
    return false;
  }

  @override
  bool onDragCancel() {
    dragDeltaPosition = null;
    return false;
  }
}
