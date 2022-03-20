import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Draggable;

import 'balls.dart';
import 'boundaries.dart';

class DraggableSample extends Forge2DGame with HasDraggables {
  DraggableSample() : super(gravity: Vector2.all(0.0));

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
    final worldDelta = Vector2(1, -1)..multiply(info.delta.game);
    body.applyLinearImpulse(worldDelta * 1000);
    return true;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    paint = originalPaint;
    return true;
  }
}
