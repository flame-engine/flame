import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class RaycastExample extends FlameGame
    with HasCollisionDetection, TapDetector, MouseMovementDetector {
  static const description = '''
  ''';
  static const tau = pi * 2;

  Ray2? ray;
  Ray2? reflection;
  Vector2? origin;
  Vector2? tapOrigin;
  Paint paint = Paint()..color = Colors.amber.withOpacity(0.2);
  Paint tapPaint = Paint()..color = Colors.blue.withOpacity(0.2);

  static const numberOfRays = 2000;
  final List<Ray2> rays = List.generate(
    numberOfRays,
    (i) => Ray2(
      Vector2.zero(),
      Vector2(0, 1)..rotate((tau / numberOfRays) * i),
    ),
    growable: false,
  );
  final List<Ray2> tapRays = List.generate(
    numberOfRays,
    (i) => Ray2(
      Vector2.all(800),
      Vector2(0, 1)..rotate((tau / numberOfRays) * i),
    ),
    growable: false,
  );

  final List<RaycastResult<ShapeHitbox>> results = List.generate(
    numberOfRays,
    (i) => RaycastResult<ShapeHitbox>(isActive: false),
    growable: false,
  );
  final List<RaycastResult<ShapeHitbox>> tapResults = List.generate(
    numberOfRays,
    (i) => RaycastResult<ShapeHitbox>(isActive: false),
    growable: false,
  );

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

  void castRays(
    Vector2 origin,
    List<Ray2> rays,
    List<RaycastResult<ShapeHitbox>> results,
  ) {
    rays.forEachIndexed((i, ray) {
      ray.origin.setFrom(origin);
      collisionDetection.raycast(rays[i], out: results[i]);
    });
  }

  @override
  bool onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    tapOrigin = info.eventPosition.game;
    castRays(tapOrigin!, tapRays, tapResults);
    return false;
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    origin = info.eventPosition.game;
    castRays(origin!, rays, results);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (origin != null) {
      renderResult(canvas, origin!, results, paint);
    }
    if (tapOrigin != null) {
      renderResult(canvas, tapOrigin!, tapResults, tapPaint);
    }
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
  }
}
