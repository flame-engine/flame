import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

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

    // Same as before, but the position is set with an anchor.
    testGolden(
      'elliptical viewport with anchor',
      (game) async {
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

    // The cross-hair should render in the center of the viewport.
    testGolden(
      'circular viewport with a HUD element',
      (game) async {
        final world = _MyWorld();
        final viewport = CircularViewport(20)..position = Vector2(5, 5);
        final camera = CameraComponent(world: world, viewport: viewport);
        viewport.add(
          _CrossHair(size: Vector2.all(16), position: viewport.size / 2),
        );
        game.addAll([world, camera]);
      },
      goldenFile: '../../_goldens/circular_viewport_test3.png',
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

      final nestedPoints = <Vector2>[];
      final center = Vector2(100, 50);
      for (final component in game.componentsAtPoint(center, nestedPoints)) {
        expect(component, world);
        expect(nestedPoints.last, Vector2.zero());
        break;
      }
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

class _CrossHair extends PositionComponent {
  _CrossHair({super.size, super.position}) : super(anchor: Anchor.center);

  final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..color = const Color(0xFFFF0000);

  @override
  void render(Canvas canvas) {
    canvas.drawLine(Offset(size.x / 2, 0), Offset(size.x / 2, size.y), _paint);
    canvas.drawLine(Offset(0, size.y / 2), Offset(size.x, size.y / 2), _paint);
  }
}
