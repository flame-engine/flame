import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class RayCastExample extends FlameGame with HasCollisionDetection {
  final origin = Vector2(20, 20);

  final direction = Vector2(1, 0);

  final velocity = 60;
  double get resetPosition => -canvasSize.y;

  Paint paint = Paint()..color = Colors.red.withOpacity(0.6);

  RaycastResult<ShapeHitbox>? result;

  @override
  Future<void> onLoad() async {
    final paint = BasicPalette.gray.paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    add(ScreenHitbox());

    add(
      CircleComponent(
        position: canvasSize / 2,
        radius: 30,
        paint: paint,
        children: [CircleHitbox()],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final ray = Ray2(
      origin: origin,
      direction: direction,
    );
    result = collisionDetection.raycast(ray);

    origin.y += velocity * dt;

    if (origin.y > canvasSize.y) {
      origin.y += resetPosition;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (result != null && result!.isActive) {
      final originOffset = origin.toOffset();
      final intersectionPoint = result!.intersectionPoint!.toOffset();
      canvas.drawLine(
        originOffset,
        intersectionPoint,
        paint,
      );

      canvas.drawCircle(originOffset, 10, paint);
    }
  }
}
