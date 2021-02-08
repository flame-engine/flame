import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/gestures.dart';

import 'package:flutter/material.dart' hide Image, Draggable;

import 'dart:ui';

void main() async {
  final game = MyGame();
  runApp(
    GameWidget(
      game: game,
    ),
  );
}

abstract class MyCollidable extends PositionComponent
    with Draggable, Hitbox, Collidable {
  double rotationSpeed = 0.4;
  final Vector2 velocity;
  final delta = Vector2.zero();
  double angleDelta = 0;
  bool _isDragged = false;
  final _activePaint = Paint()..color = Colors.amber;
  double _wallHitTime = double.infinity;

  MyCollidable(Vector2 position, Vector2 size, this.velocity) {
    this.position = position;
    this.size = size;
    hasScreenCollision = true;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isDragged) {
      return;
    }
    _wallHitTime += dt;
    delta.setFrom(velocity * dt);
    position.add(delta);
    angleDelta = dt * rotationSpeed;
    angle = (angle + angleDelta) % (2 * pi);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderShapes(canvas);
    final localCenter = (size / 2).toOffset();
    if (_isDragged) {
      canvas.drawCircle(localCenter, 5, _activePaint);
    }
    if (_wallHitTime < 1.0) {
      // Show a rectangle in the center for a second if we hit the wall
      canvas.drawRect(Rect.fromCenter(center: localCenter ,width: 10, height: 10),  debugPaint);
    }
  }

  @override
  void collisionCallback(Set<Vector2> points, Collidable other) {
    final averageIntersection =
        points.fold<Vector2>(Vector2.zero(), (sum, v) => sum + v) /
            points.length.toDouble();
    final collisionDirection = (averageIntersection - absoluteCenter)
      ..normalize()
      ..round();
    if (velocity.angleToSigned(collisionDirection).abs() > 3) {
      // This entity got hit by something else
      return;
    }
    final angleToCollision = velocity.angleToSigned(collisionDirection);
    if (angleToCollision.abs() < pi / 8) {
      velocity.rotate(pi);
    } else {
      velocity.rotate(-pi / 2 * angleToCollision.sign);
    }
    position.sub(delta * 2);
    angle = (angle - angleDelta) % (2 * pi);
    if (other is ScreenCollidable) {
      _wallHitTime = 0;
    }
  }

  @override
  bool onReceiveDrag(DragEvent event) {
    event.onUpdate = (DragUpdateDetails details) {
      _isDragged = true;
    };
    event.onEnd = (DragEndDetails details) {
      velocity.setFrom(details.velocity.pixelsPerSecond.toVector2() / 10);
      _isDragged = false;
    };
    return true;
  }
}

class CollidablePolygon extends MyCollidable {
  CollidablePolygon(Vector2 position, Vector2 size, Vector2 velocity)
      : super(position, size, velocity) {
    final shape = HitboxPolygon([
      Vector2(0, 1),
      Vector2(1, 0),
      Vector2(0, -1),
      Vector2(-1, 0),
    ]);
    addShape(shape);
  }
}

class CollidableCircle extends MyCollidable {
  CollidableCircle(Vector2 position, Vector2 size, Vector2 velocity)
      : super(position, size, velocity) {
    final shape = HitboxCircle();
    addShape(shape);
  }
}

class MyGame extends BaseGame with HasCollidables, HasDraggableComponents {
  final fpsTextConfig = TextConfig(color: const Color(0xFFFFFFFF));

  @override
  bool debugMode = false;

  @override
  Future<void> onLoad() async {
    //add(CollidablePolygon(Vector2.all(100), Vector2.all(100), 200));
    add(ScreenCollidable());
    add(CollidablePolygon(
        Vector2.all(140), Vector2.all(140), Vector2.all(100)));
    add(CollidableCircle(Vector2.all(340), Vector2.all(180), Vector2.all(180)));
    add(CollidableCircle(Vector2.all(540), Vector2.all(180), Vector2.all(138)));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (debugMode) {
      fpsTextConfig.render(canvas, fps(120).toString(), Vector2(0, 50));
    }
  }
}
