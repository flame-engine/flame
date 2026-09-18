import 'package:examples/commons/paths_creation_mixin.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class RaycastExample extends FlameGame
    with HasCollisionDetection, PathsCreationMixin {
  static const description = '''
In this example the raycast functionality is showcased. The circle moves around
and casts 10 rays and checks how far the nearest hitboxes are and naively moves
around trying not to hit them.
  ''';

  Ray2? ray;
  Ray2? reflection;
  Vector2 origin = Vector2(250, 100);
  Paint paint = Paint()..color = Colors.amber.withValues(alpha: 0.6);
  final speed = 100;
  final inertia = 3.0;
  final safetyDistance = 50;
  final direction = Vector2(0, 1);
  final velocity = Vector2.zero();

  static const numberOfRays = 12;
  final List<Ray2> rays = [];
  final List<RaycastResult<ShapeHitbox>> results = [];

  late Path path;
  @override
  Future<void> onLoad() async {
    final paint = BasicPalette.gray.paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    add(ScreenHitbox());
    addFixedPaths(paint);
    addTestPaths(paint);
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
