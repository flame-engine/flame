import 'dart:math' show max, pi, sqrt;
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
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
        _getBounds(camera)?.aabb.center,
        Vector2(320, 240),
        reason: 'Camera bounds at unexpected location (considerViewport=true)',
      );
      // Moving sideways, the camera stops where the 320x240 viewport's two
      // corners on that side reach the circle, and likewise moving up or down.
      _expectCircleRegionSize(
        camera,
        sqrt(320 * 320 - 120 * 120) - 160,
        sqrt(320 * 320 - 160 * 160) - 120,
      );

      // Check bounds after moving away from the center
      // while considerViewport = true
      camera
        ..setBounds(bounds, considerViewport: true)
        ..moveBy(Vector2(-320, 0));
      game.update(0);
      expect(
        _getBounds(camera)?.aabb.center,
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

      final center = _getBounds(camera)!.aabb.center;
      expect(center.x, closeTo(-500, 1e-9));
      expect(center.y, closeTo(700, 1e-9));
      _expectCircleRegionSize(
        camera,
        sqrt(400 * 400 - 120 * 120) - 160,
        sqrt(400 * 400 - 160 * 160) - 120,
      );
    });

    testWithFlameGame(
      'Circle lets the corners of the viewport reach it in every direction',
      (game) async {
        final camera = await _fixedResolutionCamera(game, height: 180);
        final circle = Circle(Vector2(100, -50), 300);
        await _setBounds(game, camera, circle);

        // At every vertex of the region, the farthest corner of the viewport
        // is on the circle: the viewport doesn't leave it, but the camera
        // doesn't stop before it either.
        for (final vertex in (_getBounds(camera)! as Polygon).vertices) {
          expect(
            _farthestCornerDistance(camera, circle, vertex),
            closeTo(300, 1e-3),
          );
        }
      },
    );

    testWithFlameGame('Circle region turns with the viewfinder', (game) async {
      final camera = await _fixedResolutionCamera(game, height: 180);
      camera.viewfinder.angle = pi / 6;
      final circle = Circle(Vector2(100, -50), 300);
      await _setBounds(game, camera, circle);

      for (final vertex in (_getBounds(camera)! as Polygon).vertices) {
        expect(
          _farthestCornerDistance(camera, circle, vertex),
          closeTo(300, 1e-3),
        );
      }
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
        expect(_getBounds(camera)!.aabb.min, Vector2(50, 50));
        expect(_getBounds(camera)!.aabb.max, Vector2(50, 50));

        camera.moveBy(Vector2(500, 500));
        await game.ready();
        game.update(1);
        game.update(0);
        expect(camera.viewfinder.position, Vector2(50, 50));
      },
    );

    testWithFlameGame('updates when the viewport is resized', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();
      game.onGameResize(Vector2(400, 300));
      await _setBounds(game, camera, Rectangle.fromLTRB(0, 0, 1000, 1000));
      expect(_getBoundsRect(camera), const Rect.fromLTRB(200, 150, 800, 850));

      camera.viewfinder.position = Vector2(200, 150);
      game.onGameResize(Vector2(800, 600));
      expect(_getBoundsRect(camera), const Rect.fromLTRB(400, 300, 600, 700));
      expect(camera.viewfinder.position, Vector2(400, 300));
    });

    testWithFlameGame(
      'updates when the viewport is resized without moving the anchor',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)..addToParent(game);
        // With a top-left anchor, the viewfinder's anchor point stays in place
        // when the viewport is resized.
        camera.viewfinder.anchor = Anchor.topLeft;
        await game.ready();
        game.onGameResize(Vector2(400, 300));
        await _setBounds(game, camera, Rectangle.fromLTRB(0, 0, 1000, 1000));
        expect(_getBoundsRect(camera)?.size, const Size(600, 700));

        game.onGameResize(Vector2(800, 600));
        expect(_getBoundsRect(camera)?.size, const Size(200, 400));
      },
    );

    testWithFlameGame('updates when the viewport is replaced', (game) async {
      final camera = await _fixedResolutionCamera(game);
      await _setBounds(game, camera, Rectangle.fromLTRB(0, 0, 640, 480));
      expect(_getBoundsRect(camera), const Rect.fromLTRB(160, 120, 480, 360));

      camera.viewport = FixedSizeViewport(400, 200);
      await game.ready();
      expect(_getBoundsRect(camera), const Rect.fromLTRB(200, 100, 440, 380));
    });

    testWithFlameGame('keeps updating after being mounted again', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();
      game.onGameResize(Vector2(400, 300));
      await _setBounds(game, camera, Rectangle.fromLTRB(0, 0, 1000, 1000));

      // Removing the camera and adding it back mounts the behavior again,
      // without loading it again.
      camera.removeFromParent();
      await game.ready();
      game.add(camera);
      await game.ready();

      game.onGameResize(Vector2(800, 600));
      expect(_getBoundsRect(camera), const Rect.fromLTRB(400, 300, 600, 700));
    });

    testWithFlameGame('updates when the angle changes', (game) async {
      final camera = await _fixedResolutionCamera(game);
      await _setBounds(game, camera, Rectangle.fromLTRB(0, 0, 640, 480));
      expect(_getBoundsRect(camera), const Rect.fromLTRB(160, 120, 480, 360));

      camera.viewfinder.angle = pi / 2;
      final bounds = _getBoundsRect(camera)!;
      // The visible region is now 240x320.
      expect(bounds.left, closeTo(120, 1e-9));
      expect(bounds.top, closeTo(160, 1e-9));
      expect(bounds.right, closeTo(520, 1e-9));
      expect(bounds.bottom, closeTo(320, 1e-9));
    });
  });
}

Shape? _getBounds(CameraComponent camera) =>
    camera.viewfinder.firstChild<BoundedPositionBehavior>()?.bounds;

/// Checks how far the region for circle bounds reaches from their center
/// along the horizontal and the vertical axis.
void _expectCircleRegionSize(
  CameraComponent camera,
  double halfWidth,
  double halfHeight,
) {
  final aabb = _getBounds(camera)!.aabb;
  expect((aabb.max.x - aabb.min.x) / 2, closeTo(halfWidth, 1e-3));
  expect((aabb.max.y - aabb.min.y) / 2, closeTo(halfHeight, 1e-3));
}

/// The distance between the center of the [circle] and the corner of the
/// visible region that is farthest from it, with the viewfinder at
/// [position].
double _farthestCornerDistance(
  CameraComponent camera,
  Circle circle,
  Vector2 position,
) {
  camera.viewfinder.position = position;
  final size = camera.viewport.virtualSize;
  return [
        Vector2.zero(),
        Vector2(size.x, 0),
        size.clone(),
        Vector2(0, size.y),
      ]
      .map((corner) {
        return camera.viewfinder
            .globalToLocal(corner)
            .distanceTo(circle.center);
      })
      .reduce(max);
}

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
