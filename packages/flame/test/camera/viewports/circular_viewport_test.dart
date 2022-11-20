import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('CircularViewport', () {
    // This should produce a white ellipse on a black background. The ellipse
    // should be centered within the image, and has no anti-aliasing.
    testGolden(
      'elliptical viewport',
      (game) async {
        final world = _MyWorld();
        final camera = CameraComponent(
          world: world,
          viewport: CircularViewport.ellipse(80, 20)
            ..position = Vector2(20, 30),
        );
        game.addAll([world, camera]);
      },
      goldenFile: '../../_goldens/circular_viewport_test1.png',
      size: Vector2(200, 100),
    );

    // Renders magenta border around the viewport's edge
    testGolden(
      'circular viewport with debug mode',
      (game) async {
        final world = _MyWorld();
        final camera = CameraComponent(
          world: world,
          viewport: CircularViewport(20)
            ..position = Vector2(5, 5)
            ..debugMode = true,
        );
        game.addAll([world, camera]);
      },
      goldenFile: '../../_goldens/circular_viewport_test2.png',
      size: Vector2(50, 50),
    );

    // Modifies the viewport after it was initially initialized, and ensures
    // that the new clip mask matches what we'd expect.
    testGolden(
      'circular viewport after resize',
      (game) async {
        final world = _MyWorld();
        final camera = CameraComponent(
          world: world,
          viewport: CircularViewport.ellipse(5, 10)..debugMode = true,
        );
        game.addAll([world, camera]);
        await game.ready();
        camera.viewport.position = Vector2(5, 5);
        camera.viewport.size = Vector2(40, 40);
      },
      goldenFile: '../../_goldens/circular_viewport_test2.png',
      size: Vector2(50, 50),
    );

    testWithFlameGame('hit testing', (game) async {
      final world = _MyWorld();
      final camera = CameraComponent(
        world: world,
        viewport: CircularViewport.ellipse(80, 20)..position = Vector2(20, 30),
      );
      game.addAll([world, camera]);
      await game.ready();

      bool hit(double x, double y) {
        return game.componentsAtPoint(Vector2(x, y)).first == world;
      }

      expect(hit(10, 20), false);
      expect(hit(20, 30), false);
      expect(hit(25, 35), false);
      expect(hit(100, 35), true);
      expect(hit(100, 50), true);
      expect(hit(180, 50), true);
      expect(hit(180, 49), false);
      expect(hit(180, 51), false);
    });

    test('set wrong size', () {
      expect(
        () => CircularViewport(-1.0),
        failsAssert("Viewport's size cannot be negative: [-2.0,-2.0]"),
      );
      expect(
        () => CircularViewport(0)..size = Vector2(-3.0, 4.0),
        failsAssert("Viewport's size cannot be negative: [-3.0,4.0]"),
      );
    });
  });
}

class _MyWorld extends World {
  @override
  void render(Canvas canvas) {
    canvas.drawColor(const Color(0xFFFFFFFF), BlendMode.src);
  }
}
