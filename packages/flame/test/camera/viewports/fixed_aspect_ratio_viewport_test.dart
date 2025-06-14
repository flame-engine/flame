import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('FixedAspectRatioViewport', () {
    testGolden(
      'viewport with tall screen',
      (game, tester) async {
        final world = _MyWorld();
        final camera = CameraComponent(
          world: world,
          viewport: FixedAspectRatioViewport(aspectRatio: 1.5),
        );
        game.addAll([world, camera]);
      },
      goldenFile: '../../_goldens/fixed_aspect_ratio_viewport_test1.png',
      size: Vector2(100, 200),
    );

    testGolden(
      'viewport with wide screen',
      (game, tester) async {
        final world = _MyWorld();
        final camera = CameraComponent(
          world: world,
          viewport: FixedAspectRatioViewport(aspectRatio: 1.5),
        );
        game.addAll([world, camera]);
      },
      goldenFile: '../../_goldens/fixed_aspect_ratio_viewport_test2.png',
      size: Vector2(200, 100),
    );

    testWithFlameGame('auto-resizing', (game) async {
      final viewport = FixedAspectRatioViewport(aspectRatio: 2.0);
      final camera = CameraComponent(
        world: World()..addToParent(game),
        viewport: viewport,
      );
      game.add(camera);
      await game.ready();

      final random = Random();
      for (var i = 0; i < 20; i++) {
        // keep it as a float32 value
        final width = prevFloat32(random.nextDouble() * 1000.0 + 10.0);
        final height = prevFloat32(random.nextDouble() * 1000.0 + 10.0);
        game.onGameResize(Vector2(width, height));
        expect(viewport.size.x == width || viewport.size.y == height, true);
        expect(
          viewport.size.x / viewport.size.y,
          closeTo(2.0, toleranceFloat32(2.0)),
        );
        if (viewport.size.x == width) {
          expect(viewport.position.x, 0);
          expect(
            viewport.position.y * 2 + viewport.size.y,
            closeTo(height, toleranceFloat32(height)),
          );
        }
        if (viewport.size.y == height) {
          expect(viewport.position.y, 0);
          expect(
            viewport.position.x * 2 + viewport.size.x,
            closeTo(width, toleranceFloat32(width)),
          );
        }
      }
    });

    testWithFlameGame('hit testing', (game) async {
      final world = World();
      final viewport = FixedAspectRatioViewport(aspectRatio: 1);
      final camera = CameraComponent(
        world: world,
        viewport: viewport,
      );
      game.addAll([world, camera]);
      game.onGameResize(Vector2(100, 200));
      await game.ready();

      bool hit(double x, double y) {
        final components = game.componentsAtPoint(Vector2(x, y)).toList();
        return components.isNotEmpty &&
            components.first == viewport &&
            components[1] == world;
      }

      for (final x in [0.0, 5.0, 50.0, 100.0]) {
        expect(hit(x, 1), false);
        expect(hit(x, 45), false);
        expect(hit(x, 50), true);
        expect(hit(x, 100), true);
        expect(hit(x, 150), true);
        expect(hit(x, 155), false);
        expect(hit(x, 199), false);
      }
    });
  });
}

class _MyWorld extends World {
  @override
  void render(Canvas canvas) {
    canvas.drawColor(const Color(0xFF777777), BlendMode.src);
  }
}
