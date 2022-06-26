import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';

class RaycastExample extends FlameGame
    with HasCollisionDetection, TapDetector, MouseMovementDetector {
  static const description = '''
  ''';
  static const tau = pi * 2;

  Ray2? ray;
  Ray2? reflection;
  Vector2? origin;

  static const numberOfRays = 100;
  final List<Ray2> rays = List.generate(
    numberOfRays,
    (i) => Ray2(Vector2.zero(), Vector2.zero()),
    growable: false,
  );
  final List<RaycastResult<ShapeHitbox>> results = List.generate(
    numberOfRays,
    (i) => RaycastResult<ShapeHitbox>(),
    growable: false,
  );

  @override
  Future<void> onLoad() async {
    debugMode = true;
    add(
      RectangleComponent(position: Vector2.all(300), size: Vector2.all(100))
        ..add(RectangleHitbox()),
    );
  }

  @override
  void onTapDown(TapDownInfo info) {
    origin = info.eventPosition.game;
    castRays();
  }

  void castRays() {
    rays.forEachIndexed((i, ray) {
      ray.origin.setFrom(origin!);
      ray.direction
        ..setValues(1, 0)
        ..rotate((tau / numberOfRays) * i);
      collisionDetection.raycast(rays[i], out: results[i]);
    });
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    origin = info.eventPosition.game;
    castRays();
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (origin != null) {
      c.drawCircle(origin!.toOffset(), 10, debugPaint);
    }
    if (ray != null && reflection != null) {
      c.drawLine(
        ray!.origin.toOffset(),
        reflection!.origin.toOffset(),
        debugPaint,
      );
      c.drawLine(
        reflection!.origin.toOffset(),
        reflection!.origin.toOffset() +
            reflection!.direction.scaled(100).toOffset(),
        debugPaint,
      );
    }

    if (origin == null) {
      return;
    }
    final originOffset = origin!.toOffset();
    for (final result in results) {
      if (!result.isActive) {
        continue;
      }
      final intersectionPoint = result.reflectionRay!.origin.toOffset();
      //print(intersectionPoint);
      c.drawLine(
        originOffset,
        intersectionPoint,
        debugPaint,
      );
    }
    //print('stop');
  }
}
