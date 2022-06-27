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
  late final DraggableEmber square;

  DraggablesExample({required this.zoom});

  @override
  Future<void> onLoad() async {
    camera.zoom = zoom;
    add(square = DraggableEmber());
    add(DraggableEmber()..y = 350);
  }
}

// Note: this component does not consider the possibility of multiple
// simultaneous drags with different pointerIds.
class DraggableEmber extends Ember with Draggable {
  @override
  bool debugMode = true;

  DraggableEmber({Vector2? position})
      : super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
        );

  @override
  void update(double dt) {
    super.update(dt);
    debugColor = isDragged && parent is DraggablesExample
        ? Colors.greenAccent
        : Colors.purple;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    if (parent is! DraggablesExample) {
      return true;
    }

    position.add(info.delta.game);
    return false;
  }
}
