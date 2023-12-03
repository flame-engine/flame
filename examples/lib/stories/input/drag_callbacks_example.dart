import 'package:examples/commons/ember.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors;

class DragCallbacksExample extends FlameGame {
  static const String description = '''
    In this example we show you can use the `DragCallbacks` mixin on
    `PositionComponent`s. Drag around the Embers and see their position
    changing.
  ''';

  DragCallbacksExample({required this.zoom});

  final double zoom;
  late final DraggableEmber square;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.zoom = zoom;
    world.add(square = DraggableEmber());
    world.add(DraggableEmber()..y = 350);
  }
}

// Note: this component does not consider the possibility of multiple
// simultaneous drags with different pointerIds.
class DraggableEmber extends Ember with DragCallbacks {
  @override
  bool debugMode = true;

  DraggableEmber({super.position}) : super(size: Vector2.all(100));

  @override
  void update(double dt) {
    super.update(dt);
    debugColor = isDragged ? Colors.greenAccent : Colors.purple;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }
}
