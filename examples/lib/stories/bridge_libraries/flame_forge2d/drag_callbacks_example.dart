import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Draggable;

class DragCallbacksExample extends Forge2DGame {
  static const description = '''
    In this example we use Flame's normal `DragCallbacks` mixin to give impulses
    to a ball when we are dragging it around. If you are interested in dragging
    bodies around, also have a look at the MouseJointExample.
  ''';

  DragCallbacksExample() : super(gravity: Vector2.all(0.0));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(this);
    world.addAll(boundaries);
    world.add(DraggableBall(Vector2.zero()));
  }
}

class DraggableBall extends Ball with DragCallbacks {
  DraggableBall(super.position) : super(radius: 5) {
    originalPaint = Paint()..color = Colors.amber;
    paint = originalPaint;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    paint = randomPaint();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    body.applyLinearImpulse(event.localDelta * 1000);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    paint = originalPaint;
  }
}
