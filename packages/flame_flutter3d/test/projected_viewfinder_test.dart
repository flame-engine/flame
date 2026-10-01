/// Flame's own hit test and conversions, through a perspective 3D camera.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter_test/flutter_test.dart';

final class _Crate extends PositionComponent with TapCallbacks {
  _Crate(Vector2 at)
    : super(position: at, size: Vector2.all(1.0), anchor: Anchor.center);
}

void main() {
  final eye = CameraNode()
    ..setPosition(0.0, 6.0, 6.0)
    ..lookAt(Vector3(0.0, 0.0, -6.0));
  final plane = BridgePlane.ground();

  FlameGame projected() {
    late final FlameGame game;
    final world = World();
    return game = FlameGame(
      world: world,
      camera: CameraComponent(
        world: world,
        viewfinder: ProjectedViewfinder(
          projector: BridgeProjector(camera: eye, viewSize: () => game.size),
          plane: plane,
        ),
      ),
    );
  }

  testWithGame<FlameGame>(
    'a point on the screen is the point of the plane drawn there',
    projected,
    (game) async {
      // Mutation: map the screen through the viewfinder's affine transform.
      final crate = _Crate(Vector2(2.0, -8.0));
      game.world.add(crate);
      await game.ready();

      final projector = BridgeProjector(camera: eye, viewSize: () => game.size);
      final screen = projector.toScreen(plane.to3d(crate.position))!;
      final back = game.camera.globalToLocal(screen);
      expect(back.x, closeTo(2.0, 1e-3));
      expect(back.y, closeTo(-8.0, 1e-3));

      expect(game.componentsAtPoint(screen), contains(crate));
      expect(
        game.camera.localToGlobal(crate.position).distanceTo(screen),
        lessThan(1e-3),
      );
    },
  );

  testWithGame<FlameGame>(
    'what the camera can see is what the 3D camera shows',
    projected,
    (game) async {
      // Worked out from the viewfinder's own offset and zoom, the rectangle
      // was one nobody was looking at under a perspective lens.
      //
      // Mutation: keep Flame's affine visible rectangle.
      final ahead = _Crate(Vector2(2.0, -8.0));
      final behind = _Crate(Vector2(0.0, 20.0));
      game.world.addAll(<Component>[ahead, behind]);
      await game.ready();
      game.update(0.0);

      final seen = game.camera.visibleWorldRect;
      expect(seen.contains(const Offset(2.0, -8.0)), isTrue);
      expect(seen.bottom, lessThan(6.0), reason: 'nothing behind the eye');
      expect(game.camera.canSee(ahead), isTrue);
      expect(game.camera.canSee(behind), isFalse);
    },
  );

  test('a projector for half the canvas draws into that half, and reads '
      'taps from it', () {
    // The other half of a split screen: the lens is the half's shape and
    // the screen is still the canvas.
    //
    // Mutation: project over the whole canvas whatever the viewport.
    final half = BridgeProjector(
      camera: eye,
      viewSize: () => Vector2(800.0, 300.0),
      viewport: () => const ViewportRect(0.5, 0.0, 0.5, 1.0),
    );
    final alone = BridgeProjector(
      camera: eye,
      viewSize: () => Vector2(400.0, 300.0),
    );
    final point = plane.to3d(Vector2(1.0, -8.0));
    final there = half.toScreen(point)!;
    final solo = alone.toScreen(point)!;
    expect(there.x, closeTo(solo.x + 400.0, 1e-3));
    expect(there.y, closeTo(solo.y, 1e-3));
    final back = half.onPlane(there, plane)!;
    expect(back.x, closeTo(1.0, 1e-3));
    expect(back.y, closeTo(-8.0, 1e-3));
  });

  testWithGame<FlameGame>(
    'through a fixed-resolution viewport, a tap still lands on the crate',
    () {
      late final FlameGame game;
      final world = World();
      return game = FlameGame(
        world: world,
        camera: CameraComponent.withFixedResolution(
          width: 400.0,
          height: 300.0,
          world: world,
          viewfinder: ProjectedViewfinder(
            projector: BridgeProjector(camera: eye, viewSize: () => game.size),
            plane: plane,
          ),
        ),
      );
    },
    (game) async {
      // Flame hands the viewfinder points in the viewport's frame, and the
      // projector works in the canvas: every tap landed elsewhere.
      //
      // Mutation: project the viewport's point as it comes.
      final crate = _Crate(Vector2(2.0, -8.0));
      game.world.add(crate);
      await game.ready();

      final projector = BridgeProjector(camera: eye, viewSize: () => game.size);
      final screen = projector.toScreen(plane.to3d(crate.position))!;
      expect(game.componentsAtPoint(screen), contains(crate));
    },
  );

  testWithGame<FlameGame>(
    'the sky is the far horizon, and hits nothing near',
    () {
      late final FlameGame game;
      final world = World();
      final level = CameraNode()
        ..setPosition(0.0, 2.0, 0.0)
        ..lookAt(Vector3(0.0, 2.0, -10.0));
      return game = FlameGame(
        world: world,
        camera: CameraComponent(
          world: world,
          viewfinder: ProjectedViewfinder(
            projector: BridgeProjector(
              camera: level,
              viewSize: () => game.size,
            ),
            plane: plane,
          ),
        ),
      );
    },
    (game) async {
      final crate = _Crate(Vector2.zero());
      game.world.add(crate);
      await game.ready();
      // A NaN reached World's own tap handlers, and a drag that strayed
      // above the horizon put its component at NaN for good.
      //
      // Mutation: hand back NaN for the sky.
      final sky = Vector2(game.size.x / 2, 2.0);
      final there = game.camera.globalToLocal(sky);
      expect(there.x.isFinite && there.y.isFinite, isTrue);
      expect(there.y, lessThan(-50.0), reason: 'out ahead, at the horizon');
      expect(game.componentsAtPoint(sky), isNot(contains(crate)));
    },
  );
}
