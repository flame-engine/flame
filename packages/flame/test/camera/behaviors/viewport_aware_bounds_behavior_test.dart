import 'dart:math' show pi;
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewportAwareBoundsBehavior', () {
    testWithFlameGame('setBounds wrt Rectangle', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent.withFixedResolution(
        width: 320,
        height: 240,
        world: world,
      )..addToParent(game);
      await game.ready();
      final bounds = Rectangle.fromLTRB(0, 0, 640, 480);

      // With considerViewport = false
      camera.setBounds(bounds);
      game.update(0);
      expect(
        (_getBounds(camera) as Rectangle?)?.toRect(),
        Rectangle.fromLTRB(0, 0, 640, 480).toRect(),
        reason: 'Camera bounds at unexpected location',
      );

      expect(camera.viewfinder.considerViewport, false);

      // With considerViewport = true
      camera.setBounds(bounds, considerViewport: true);
      game.update(0);
      expect(
        (_getBounds(camera) as Rectangle?)?.toRect(),
        Rectangle.fromLTRB(160, 120, 480, 360).toRect(),
        reason: 'Camera bounds did not consider viewport',
      );

      expect(camera.viewfinder.considerViewport, true);
    });

    testWithFlameGame('setBounds wrt RoundedRectangle', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent.withFixedResolution(
        width: 320,
        height: 240,
        world: world,
      )..addToParent(game);
      await game.ready();
      final bounds = RoundedRectangle.fromLTRBR(0, 0, 640, 480, 32);

      // With considerViewport = false
      camera.setBounds(bounds);
      game.update(0);
      expect(
        (_getBounds(camera) as RoundedRectangle?)?.asRRect(),
        RoundedRectangle.fromLTRBR(0, 0, 640, 480, 32).asRRect(),
        reason: 'Camera bounds at unexpected location',
      );

      expect(camera.viewfinder.considerViewport, false);

      // With considerViewport = true
      camera.setBounds(bounds, considerViewport: true);
      game.update(0);
      expect(
        (_getBounds(camera) as RoundedRectangle?)?.asRRect(),
        RoundedRectangle.fromLTRBR(160, 120, 480, 360, 32).asRRect(),
        reason: 'Camera bounds did not consider viewport',
      );

      expect(camera.viewfinder.considerViewport, true);
    });

    testWithFlameGame('setBounds wrt Circle', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent.withFixedResolution(
        width: 320,
        height: 240,
        world: world,
      )..addToParent(game);
      await game.ready();
      final bounds = Circle(Vector2(320, 240), 320);

      // With considerViewport = false
      camera.setBounds(bounds);
      game.update(0);
      expect(
        (_getBounds(camera) as Circle?)?.center,
        Vector2(320, 240),
        reason: 'Camera bounds at unexpected location (considerViewport=false)',
      );

      expect(camera.viewfinder.considerViewport, false);

      // With considerViewport = true
      camera.setBounds(bounds, considerViewport: true);
      game.update(0);
      expect(
        (_getBounds(camera) as Circle?)?.center,
        Vector2(320, 240),
        reason: 'Camera bounds at unexpected location (considerViewport=true)',
      );
      // The viewport's corners have to stay within the circle, so the
      // radius is reduced by half of the viewport's diagonal (400 / 2).
      expect((_getBounds(camera) as Circle?)?.radius, 120);

      // Check bounds after moving away from the center
      // while considerViewport = true
      camera
        ..setBounds(bounds, considerViewport: true)
        ..moveBy(Vector2(-320, 0));
      game.update(0);
      expect(
        (_getBounds(camera) as Circle?)?.center,
        Vector2(320, 240),
        reason: 'Camera bounds did not consider viewport after move',
      );

      expect(camera.viewfinder.considerViewport, true);
    });

    testWithFlameGame('setBounds explicit null Shape request', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent.withFixedResolution(
        width: 320,
        height: 240,
        world: world,
      )..addToParent(game);
      await game.ready();
      final bounds = Circle(Vector2(320, 240), 320);

      camera.setBounds(bounds);
      game.update(0);
      expect(
        _getBounds(camera) as Circle?,
        isNotNull,
        reason: 'Camera bounds was null but expected a non-null Circle',
      );

      camera.setBounds(null);
      game.update(0);
      expect(
        _getBounds(camera) as Circle?,
        isNull,
        reason:
            'Camera bounds expected to be null from side-effect of removing it',
      );
    });

    testWithFlameGame('Rectangle centered at the origin', (game) async {
      final camera = await _fixedResolutionCamera(game);
      await _setBounds(game, camera, Rectangle.fromLTRB(-320, -240, 320, 240));

      expect(_getBoundsRect(camera), const Rect.fromLTRB(-160, -120, 160, 120));
    });

    testWithFlameGame('Rectangle away from the origin', (game) async {
      final camera = await _fixedResolutionCamera(game);
      await _setBounds(
        game,
        camera,
        Rectangle.fromLTRB(1000, 1000, 1640, 1480),
      );

      expect(
        _getBoundsRect(camera),
        const Rect.fromLTRB(1160, 1120, 1480, 1360),
      );
    });

    testWithFlameGame('RoundedRectangle away from the origin', (game) async {
      final camera = await _fixedResolutionCamera(game);
      await _setBounds(
        game,
        camera,
        RoundedRectangle.fromLTRBR(-1000, 500, -360, 980, 32),
      );

      expect(
        (_getBounds(camera) as RoundedRectangle?)?.asRRect(),
        RoundedRectangle.fromLTRBR(-840, 620, -520, 860, 32).asRRect(),
      );
    });

    testWithFlameGame(
      'RoundedRectangle with a radius that does not fit into the region',
      (game) async {
        final camera = await _fixedResolutionCamera(game);
        // Half of the diagonal of the 320x240 viewport is 200, so it only
        // fits into a circle with a radius of 200 at the center.
        await _setBounds(
          game,
          camera,
          RoundedRectangle.fromLTRBR(0, 0, 400, 400, 200),
        );
        final circleRegion = _getBounds(camera)!;
        expect(circleRegion.aabb.min, Vector2(200, 200));
        expect(circleRegion.aabb.max, Vector2(200, 200));

        // In a pill-shaped level, the viewport can't get as close to the left
        // and right ends as to the top and bottom edges.
        final pill = RoundedRectangle.fromLTRBR(0, 0, 2000, 400, 200);
        await _setBounds(game, camera, pill);
        final region = _getBounds(camera)!;
        expect(region.containsPoint(Vector2(1790, 200)), isTrue);
        expect(region.containsPoint(Vector2(1810, 200)), isFalse);
        expect(region.containsPoint(Vector2(1000, 279)), isTrue);
        expect(region.containsPoint(Vector2(1000, 281)), isFalse);
        final corners = [
          Vector2(-160, -120),
          Vector2(160, -120),
          Vector2(-160, 120),
          Vector2(160, 120),
        ];
        for (final vertex in (region as Polygon).vertices) {
          for (final corner in corners) {
            // The vertices lie on the edge of the region, so their corners
            // lie on the edge of the bounds.
            final point = vertex + corner * 0.9999;
            expect(pill.containsPoint(point), isTrue, reason: '$point');
          }
        }
      },
    );

    testWithFlameGame('Circle away from the origin', (game) async {
      final camera = await _fixedResolutionCamera(game);
      await _setBounds(game, camera, Circle(Vector2(-500, 700), 400));

      final bounds = _getBounds(camera) as Circle?;
      expect(bounds?.center, Vector2(-500, 700));
      expect(bounds?.radius, 200);
    });

    testWithFlameGame('takes the zoom into account', (game) async {
      final camera = await _fixedResolutionCamera(game);
      camera.viewfinder.zoom = 2;
      await _setBounds(game, camera, Rectangle.fromLTRB(0, 0, 640, 480));

      expect(_getBoundsRect(camera), const Rect.fromLTRB(80, 60, 560, 420));

      camera.viewfinder.zoom = 0.8;
      expect(_getBoundsRect(camera), const Rect.fromLTRB(200, 150, 440, 330));
    });

    testWithFlameGame('takes the angle into account', (game) async {
      final camera = await _fixedResolutionCamera(game);
      camera.viewfinder.angle = pi / 2;
      await _setBounds(game, camera, Rectangle.fromLTRB(0, 0, 640, 480));

      final bounds = _getBoundsRect(camera)!;
      // The visible region is 240x320.
      expect(bounds.left, closeTo(120, 1e-9));
      expect(bounds.top, closeTo(160, 1e-9));
      expect(bounds.right, closeTo(520, 1e-9));
      expect(bounds.bottom, closeTo(320, 1e-9));
    });

    testWithFlameGame(
      'collapses to the center when the bounds are smaller than the viewport',
      (game) async {
        final camera = await _fixedResolutionCamera(game);
        await _setBounds(game, camera, Rectangle.fromLTRB(0, 0, 200, 400));

        // Narrower than the viewport, but taller.
        expect(_getBoundsRect(camera), const Rect.fromLTRB(100, 120, 100, 280));

        await _setBounds(game, camera, Circle(Vector2(50, 50), 150));
        expect((_getBounds(camera) as Circle?)?.radius, 0);

        camera.moveBy(Vector2(500, 500));
        await game.ready();
        game.update(1);
        game.update(0);
        expect(camera.viewfinder.position, Vector2(50, 50));
      },
    );
  });
}

Shape? _getBounds(CameraComponent camera) =>
    camera.viewfinder.firstChild<BoundedPositionBehavior>()?.bounds;

Rect? _getBoundsRect(CameraComponent camera) =>
    (_getBounds(camera) as Rectangle?)?.toRect();

Future<CameraComponent> _fixedResolutionCamera(
  FlameGame game, {
  double width = 320,
  double height = 240,
}) async {
  final world = World()..addToParent(game);
  final camera = CameraComponent.withFixedResolution(
    width: width,
    height: height,
    world: world,
  )..addToParent(game);
  await game.ready();
  return camera;
}

Future<void> _setBounds(
  FlameGame game,
  CameraComponent camera,
  Shape bounds,
) async {
  camera.setBounds(bounds, considerViewport: true);
  await game.ready();
  game.update(0);
}
