import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors;

class DraggablesMultipleExample extends FlameGame {
  static const String description = '''
    In this example we show you can use the `DragCallbacks` mixin on
    `PositionComponent`s. Drag around the Embers and see their position
    changing.
  ''';

  DraggablesMultipleExample({required this.zoom});

  final double zoom;
  late final DraggableEmber square;
  static const int maxItems = 1000000;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.zoom = zoom;
    final interactiveComponents = Component();
    interactiveComponents.add(square = DraggableEmber());
    interactiveComponents.add(DraggableEmber()..y = 350);
    world.add(interactiveComponents);

    componentsAtPointRoot = interactiveComponents;

    for (var i = 1; i < maxItems + 1; i++) {
      world.add(Component());
    }
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
    debugColor = isDragged && findGame() is DraggablesMultipleExample
        ? Colors.greenAccent
        : Colors.purple;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (findGame() is! DraggablesMultipleExample) {
      event.continuePropagation = true;
      return;
    }

    position.add(event.delta);
    event.continuePropagation = false;
  }
}
