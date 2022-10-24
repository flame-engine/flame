import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class RayTraceExample extends FlameGame
    with HasCollisionDetection, TapDetector {
  Paint paint = Paint()..color = Colors.red.withOpacity(0.6);
  bool isClicked = false;

  Vector2 get origin => canvasSize / 2;

  RaycastResult<ShapeHitbox>? result;

  final Ray2 _ray = Ray2.zero();

  final boxPaint = BasicPalette.gray.paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final List<RaycastResult<ShapeHitbox>> results = [];

  @override
  Future<void> onLoad() async {
    add(
      CircleComponent(
        radius: min(camera.canvasSize.x, camera.canvasSize.y) / 2,
        paint: boxPaint,
        children: [CircleHitbox()],
      ),
    );
  }

  var _timePassed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (isClicked) {
      _timePassed += dt;
    }

    result = collisionDetection.raycast(_ray);

    _ray.origin.setFrom(origin);
    _ray.direction
      ..setValues(1, 1)
      ..normalize();
    collisionDetection
        .raytrace(
          _ray,
          maxDepth: min((_timePassed * 8).ceil(), 1000),
          out: results,
        )
        .toList();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    var originOffset = origin.toOffset();
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
      originOffset = intersectionPoint;
    }
  }

  @override
  void onTap() {
    super.onTap();
    if (!isClicked) {
      isClicked = true;
      return;
    }
    _timePassed = 0;
  }
}
