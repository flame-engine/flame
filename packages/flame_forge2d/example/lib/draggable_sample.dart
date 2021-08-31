import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:forge2d/forge2d.dart';

import 'balls.dart';
import 'boundaries.dart';

class DraggableSample extends Forge2DGame with HasDraggableComponents {
  DraggableSample() : super(gravity: Vector2.all(0.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
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
  bool onDragStart(int pointerId, DragStartInfo details) {
    paint = randomPaint();
    return true;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo details) {
    final worldDelta = Vector2(1, -1)..multiply(details.delta.game);
    body.applyLinearImpulse(worldDelta * 1000);
    return true;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo details) {
    paint = originalPaint;
    return true;
  }
}
