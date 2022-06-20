import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';

class RaycastExample extends FlameGame with HasCollisionDetection, TapDetector {
  static const description = '''
  ''';

  Ray2? ray;
  Ray2? reflection;

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
    final direction = info.eventPosition.game.normalized();
    print(direction);
    ray = Ray2(Vector2.zero(), direction);
    reflection = collisionDetection.raycast(ray!)?.ray;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (ray != null && reflection != null) {
      c.drawLine(
        ray!.origin.toOffset(),
        reflection!.origin.toOffset(),
        debugPaint,
      );
      c.drawLine(
        reflection!.origin.toOffset(),
        reflection!.direction.scaled(10).toOffset(),
        debugPaint,
      );
    }
  }
}
