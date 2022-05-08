import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('FixedSizeViewport', () {
    testWithFlameGame('camera with FixedSizeViewport', (game) async {
      final camera = CameraComponent(
        world: World(),
        viewport: FixedSizeViewport(300, 100),
      );
      game.addAll([camera.world, camera]);
      await game.ready();

      expect(camera.viewport, isA<FixedSizeViewport>());
      expect(camera.viewport.size, Vector2(300, 100));
      expect(camera.viewport.position, Vector2(150, 50));

      game.onGameResize(Vector2(200, 200));
      expect(camera.viewport.size, Vector2(300, 100));
      expect(camera.viewport.position, Vector2(150, 50));
    });

    testWithFlameGame('hit-testing', (game) async {
      final camera = CameraComponent(
        world: World(),
        viewport: FixedSizeViewport(400, 100),
      );
      game.addAll([camera.world, camera]);
      await game.ready();

      final viewport = camera.viewport;
      expect(viewport, isA<FixedSizeViewport>());
      expect(viewport.containsLocalPoint(Vector2(0, 0)), true);
      expect(viewport.containsLocalPoint(Vector2(-1, -1)), true);
      expect(viewport.containsLocalPoint(Vector2(150, 50)), true);
      expect(viewport.containsLocalPoint(Vector2(-150, -50)), true);
      expect(viewport.containsLocalPoint(Vector2(-150, 50)), true);
      expect(viewport.containsLocalPoint(Vector2(150, -50)), true);
      expect(viewport.containsLocalPoint(Vector2(100, 200)), false);
      expect(viewport.containsLocalPoint(Vector2(1000, -1000)), false);
      expect(viewport.containsLocalPoint(Vector2(300, 100)), false);
    });

  });
}
