import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('MaxViewport', () {
    testWithFlameGame('camera with MaxViewport', (game) async {
      expect(game.size, Vector2(800, 600));
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      expect(camera.viewport, isA<MaxViewport>());
      expect(camera.viewport.size, Vector2(800, 600));
      expect(camera.viewport.position, Vector2(0, 0));

      game.onGameResize(Vector2(500, 200));
      expect(camera.viewport.size, Vector2(500, 200));
      expect(camera.viewport.position, Vector2(0, 0));
    });

    testWithFlameGame('hit-testing', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      final viewport = camera.viewport;
      expect(viewport, isA<MaxViewport>());
      expect(viewport.containsLocalPoint(Vector2(0, 0)), true);
      expect(viewport.containsLocalPoint(Vector2(100, 200)), true);
      expect(viewport.containsLocalPoint(Vector2(-1, -1)), true);
      expect(viewport.containsLocalPoint(Vector2(1000, -1000)), true);
    });

    testWithFlameGame('check that onViewportResize is called', (game) async {
      final world = World();
      final camera = CameraComponent(world: world, viewport: _MyMaxViewport());
      game.addAll([world, camera]);
      await game.ready();

      final viewport = camera.viewport;
      expect(viewport, isA<_MyMaxViewport>());
      expect((viewport as _MyMaxViewport).onViewportResizeCalled, 1);
      game.onGameResize(Vector2(200, 200));
      expect(viewport.onViewportResizeCalled, 2);
    });
  });
}

class _MyMaxViewport extends MaxViewport {
  int onViewportResizeCalled = 0;

  @override
  void onViewportResize() {
    onViewportResizeCalled++;
  }
}
