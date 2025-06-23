import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../camera_test_helpers.dart';

void main() {
  group('CircularViewport', () {
    // This should produce a white ellipse on a black background. The ellipse
    // should be centered within the image, and has no anti-aliasing.
    testGolden(
      'elliptical viewport',
      (game, tester) async {
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

    // Same as before, but the position is set with an anchor.
    testGolden(
      'elliptical viewport with anchor',
      (game, tester) async {
        final world = _MyWorld();
        final camera = CameraComponent(
          world: world,
          viewport: CircularViewport.ellipse(80, 20)
            ..anchor = Anchor.center
            ..position = Vector2(100, 50),
        );
        game.addAll([world, camera]);
      },
      goldenFile: '../../_goldens/circular_viewport_test1.png',
      size: Vector2(200, 100),
    );

    // Renders magenta border around the viewport's edge behind the world.
    testGolden(
      'circular viewport with debug mode',
      (game, tester) async {
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
      (game, tester) async {
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
      goldenFile: '../../_goldens/circular_viewport_test3.png',
      size: Vector2(50, 50),
    );

    // The cross-hair should render in the center of the viewport.
    testGolden(
      'circular viewport with a HUD element',
      (game, tester) async {
        final world = _MyWorld();
        final viewport = CircularViewport(20)..position = Vector2(5, 5);
        final camera = CameraComponent(world: world, viewport: viewport);
        viewport.add(
          CrossHair(size: Vector2.all(16), position: viewport.size / 2),
        );
        game.addAll([world, camera]);
      },
      goldenFile: '../../_goldens/circular_viewport_test4.png',
      size: Vector2(50, 50),
    );

    // Renders magenta border around the viewfinder's edge behind the world.
    // Should not be visible.
    testGolden(
      'circular viewport with debug mode',
      (game, tester) async {
        final world = _MyWorld();
        final camera = CameraComponent(
          world: world,
          viewport: CircularViewport(20)..position = Vector2(5, 5),
          viewfinder: Viewfinder()..debugMode = true,
        );
        game.addAll([world, camera]);
      },
      goldenFile: '../../_goldens/circular_viewport_test5.png',
      size: Vector2(50, 50),
    );

    testWithGame(
      'hit testing',
      () => FlameGame(
        camera: CameraComponent(
          viewport: CircularViewport.ellipse(80, 20)
            ..position = Vector2(20, 30),
          world: _MyWorld(),
        ),
      ),
      (game) async {
        await game.ready();
        final viewport = game.camera.viewport;

        bool hit(double x, double y) {
          final components = game.componentsAtPoint(Vector2(x, y)).toList();
          return components.first == viewport && components[1] == game.world;
        }

        expect(hit(10, 20), false);
        expect(hit(20, 30), false);
        expect(hit(25, 35), false);
        expect(hit(100, 35), true);
        expect(hit(100, 50), true);
        expect(hit(180, 50), true);
        expect(hit(180, 49), false);
        expect(hit(180, 51), false);

        final nestedPoints = <Vector2>[];
        final center = Vector2(100, 50);
        for (final component in game.componentsAtPoint(
          center,
          nestedPoints,
        )) {
          if (component == viewport) {
            continue;
          }
          expect(component, game.world);
          expect(nestedPoints.last, Vector2.zero());
          break;
        }
      },
    );

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
