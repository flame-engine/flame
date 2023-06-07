import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Draggable;

class DraggableExample extends Forge2DGame {
  static const description = '''
    In this example we use Flame's normal `Draggable` mixin to give impulses to
    a ball when we are dragging it around. If you are interested in dragging
    bodies around, also have a look at the MouseJointExample.
  ''';

  DraggableExample() : super(gravity: Vector2.all(0.0));

  @override
  Future<void> onLoad() async {
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    final center = screenToWorld(camera.viewport.effectiveSize / 2);
    add(DraggableBall(center));
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
    body.applyLinearImpulse(event.delta * 1000);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    paint = originalPaint;
  }
}
