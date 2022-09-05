import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class RaycastExample extends FlameGame with HasCollisionDetection {
  static const description = '''
In this example the raycast functionality is showcased. The circle moves around
and casts 10 rays and checks how far the nearest hitboxes are and naively moves
around trying not to hit them.
  ''';

  Ray2? ray;
  Ray2? reflection;
  Vector2 origin = Vector2(250, 100);
  Paint paint = Paint()..color = Colors.amber.withOpacity(0.6);
  final speed = 100;
  final inertia = 3.0;
  final safetyDistance = 50;
  final direction = Vector2(0, 1);
  final velocity = Vector2.zero();
  final random = Random();

  static const numberOfRays = 10;
  final List<Ray2> rays = [];
  final List<RaycastResult<ShapeHitbox>> results = [];

  late Path path;
  @override
  Future<void> onLoad() async {
    final paint = BasicPalette.gray.paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    add(ScreenHitbox());
    add(
      CircleComponent(
        position: Vector2(100, 100),
        radius: 50,
        paint: paint,
        children: [CircleHitbox()],
      ),
    );
    add(
      CircleComponent(
        position: Vector2(150, 500),
        radius: 50,
        paint: paint,
        children: [CircleHitbox()],
      ),
    );
    add(
      RectangleComponent(
        position: Vector2.all(300),
        size: Vector2.all(100),
        paint: paint,
        children: [RectangleHitbox()],
      ),
    );
    add(
      RectangleComponent(
        position: Vector2.all(500),
        size: Vector2(100, 200),
        paint: paint,
        children: [RectangleHitbox()],
      ),
    );
    add(
      RectangleComponent(
        position: Vector2(550, 200),
        size: Vector2(200, 150),
        paint: paint,
        children: [RectangleHitbox()],
      ),
    );
  }

  final _velocityModifier = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.raycastAll(
      origin,
      numberOfRays: numberOfRays,
      rays: rays,
      out: results,
    );
    velocity.scale(inertia);
    for (final result in results) {
      _velocityModifier
        ..setFrom(result.intersectionPoint!)
        ..sub(origin)
        ..normalize();
      if (result.distance! < safetyDistance) {
        _velocityModifier.negate();
      } else if (random.nextDouble() < 0.2) {
        velocity.add(_velocityModifier);
      }
      velocity.add(_velocityModifier);
    }
    velocity
      ..normalize()
      ..scale(speed * dt);
    origin.add(velocity);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderResult(canvas, origin, results, paint);
  }

  void renderResult(
    Canvas canvas,
    Vector2 origin,
    List<RaycastResult<ShapeHitbox>> results,
    Paint paint,
  ) {
    final originOffset = origin.toOffset();
    for (final result in results) {
      if (!result.isActive) {
        continue;
      }
      final intersectionPoint = result.intersectionPoint!.toOffset();
      canvas.drawLine(
        originOffset,
        intersectionPoint,
        paint,
      );
    }
    canvas.drawCircle(originOffset, 5, paint);
  }
}
