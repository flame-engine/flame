import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

import 'package:flutter/material.dart' hide Image;

import 'dart:ui';

void main() async {
  final game = MyGame();
  runApp(
    GameWidget(
      game: game,
    ),
  );
}

abstract class MyCollidable extends PositionComponent with Hitbox, Collidable {
  double speed;
  final direction = Vector2.all(1);
  final delta = Vector2.zero();

  MyCollidable(Vector2 position, Vector2 size, this.speed) {
    this.position = position;
    this.size = size;
    hasScreenCollision = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    delta.setFrom(direction * speed * dt);
    position.add(delta);
  }

  @override
  void collisionCallback(Set<Vector2> points, Collidable other) {
    final averageIntersection = points.fold<Vector2>(Vector2.zero(), (sum, v) => sum+v)/points.length.toDouble();
    final collisionDirection = (averageIntersection - absoluteCenter)..normalize()..round();
    if(collisionDirection.angleToSigned(direction).abs() > 3.14) {
      // This entity got hit by something else
      return;
    }
    final correction = Vector2(
      collisionDirection.x == 0 ? 1 : -1,
      collisionDirection.y == 0 ? 1 : -1,
    );
    direction.multiply(correction);
    position.sub(delta);
    if (other is CollidableScreen) {

    }
  }
}

class CollidablePolygon extends MyCollidable {
  CollidablePolygon(Vector2 position, Vector2 size, double speed) : super(position, size, speed) {
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
  CollidableCircle(Vector2 position, Vector2 size, double speed) : super(position, size, speed) {
    final shape = HitboxCircle();
    addShape(shape);
  }
}

class MyGame extends BaseGame with HasCollidables {
  final fpsTextConfig = TextConfig(color: const Color(0xFFFFFFFF));

  @override
  bool debugMode = true;

  @override
  Future<void> onLoad() async {
    //add(CollidablePolygon(Vector2.all(100), Vector2.all(100), 200));
    //add(CollidablePolygon(Vector2.all(140), Vector2.all(140), 100));
    add(CollidableCircle(Vector2.all(340), Vector2.all(180), 180));
    add(CollidableCircle(Vector2.all(540), Vector2.all(180), 138));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (debugMode) {
      fpsTextConfig.render(canvas, fps(120).toString(), Vector2(0, 50));
    }
  }
}
