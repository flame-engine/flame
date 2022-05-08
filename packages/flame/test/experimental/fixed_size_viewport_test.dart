import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

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

    FlameTester(() => FlameGame()).testGameWidget(
      'Clipping behavior',
      setUp: (game, tester) async {
        final world = World();
        final camera = CameraComponent(
          world: world,
          viewport: FixedSizeViewport(500, 200),
        )
          ..viewport.position = Vector2(400, 300)
          ..viewfinder.position = Vector2.zero();
        world.add(
          CircleComponent(
            position: Vector2.zero(),
            radius: 200,
            anchor: Anchor.center,
            paint: Paint()..color = const Color(0x4400ffff),
          ),
        );
        world.addAll([
          for (var i = -6; i <= 6; i++)
            CircleComponent(
              position: Vector2(i * 60.0 - i * i.abs() * 3, 0),
              radius: 25 - i.abs() * 3,
              anchor: Anchor.center,
            )
        ]);
        game.addAll([world, camera]);
        await game.ready();
      },
      verify: (game, tester) async {
        await expectLater(
          find.byGame<FlameGame>(),
          matchesGoldenFile('../_goldens/fixed_size_viewport_test_1.png'),
        );
      },
    );
  });
}
