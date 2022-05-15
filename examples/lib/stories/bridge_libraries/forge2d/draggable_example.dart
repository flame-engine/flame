import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Draggable;

class DraggableExample extends Forge2DGame with HasDraggables {
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

class DraggableBall extends Ball with Draggable {
  DraggableBall(Vector2 position) : super(position, radius: 5) {
    originalPaint = Paint()..color = Colors.amber;
    paint = originalPaint;
  }

  @override
  bool onDragStart(DragStartInfo info) {
    paint = randomPaint();
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    body.applyLinearImpulse(info.delta.game * 1000);
    return true;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    paint = originalPaint;
    return true;
  }
}
