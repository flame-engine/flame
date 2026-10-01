/// A [CameraSyncComponent] advances its [CameraSyncController] once per
/// Flame update.
library;

import 'package:flame/camera.dart' show Viewfinder;
import 'package:flame/components.dart' show PositionComponent;
import 'package:flame/experimental.dart' show Rectangle;
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an update carries the authoritative side across', () {
    final camera = CameraNode()..setPosition(3.0, 0.0, 4.0);
    final viewfinder = Viewfinder();
    final component = CameraSyncComponent(
      controller: CameraSyncController(
        camera: camera,
        viewfinder: viewfinder,
        plane: BridgePlane.ground(),
      ),
      priority: 10,
    );

    component.update(1 / 60);

    expect(viewfinder.position, Vector2(3.0, 4.0));
    expect(component.priority, 10);
  });

  testWithGame<FlameGame>(
    'synced from a viewfinder that follows the player, the 3D camera is '
    'where the player is this frame',
    FlameGame.new,
    (game) async {
      // Flame's camera follows its target after everything else, and a sync
      // run before it read last frame's viewfinder.
      //
      // Mutation: give the flowing-to-the-scene sync the camera priority.
      final camera = CameraNode();
      final player = _Runner();
      game.world.add(player);
      game.add(
        CameraSyncComponent(
          controller: CameraSyncController(
            camera: camera,
            viewfinder: game.camera.viewfinder,
            plane: BridgePlane.ground(),
            direction: SyncDirection.flameToScene,
          ),
        ),
      );
      game.camera.follow(player);
      await game.ready();

      for (var i = 0; i < 3; i++) {
        game.update(1 / 60);
      }
      expect(camera.readPosition().x, closeTo(player.position.x, 1e-6));
    },
  );

  testWithGame<FlameGame>(
    'added to the world, where a game adds its components, it is still '
    'where the player is this frame',
    FlameGame.new,
    (game) async {
      // A priority orders siblings only. Inside the world it ran before
      // Flame's camera, which is the world's sibling, whatever its number,
      // and the 3D camera trailed `camera.follow()` by a frame again.
      //
      // Mutation: advance the controller from this component's own update.
      final camera = CameraNode();
      final player = _Runner();
      game.world.add(player);
      game.world.add(
        CameraSyncComponent(
          controller: CameraSyncController(
            camera: camera,
            viewfinder: game.camera.viewfinder,
            plane: BridgePlane.ground(),
            direction: SyncDirection.flameToScene,
          ),
        ),
      );
      game.camera.follow(player);
      await game.ready();

      for (var i = 0; i < 3; i++) {
        game.update(1 / 60);
      }
      expect(camera.readPosition().x, closeTo(player.position.x, 1e-6));
    },
  );

  testWithGame<FlameGame>(
    "Flame's follow at a top speed, and its bounds, move a perspective "
    'camera',
    FlameGame.new,
    (game) async {
      // Mutation: sync a perspective camera by position alone.
      final camera = CameraNode(
        projection: const PerspectiveProjection(fovYRadians: 0.9),
      );
      final player = _Jumper();
      game.world.add(player);
      game.add(
        CameraSyncComponent(
          controller: CameraSyncController(
            camera: camera,
            viewfinder: game.camera.viewfinder,
            plane: BridgePlane.ground(),
            direction: SyncDirection.flameToScene,
            eyeOffset: Vector3(0.0, 10.0, 8.0),
          ),
        ),
      );
      game.camera.follow(player, maxSpeed: 60.0);
      await game.ready();

      player.position.x = 100.0;
      game.update(1 / 60);
      final eye = camera.readPosition();
      expect(eye.x, closeTo(1.0, 1e-6), reason: 'a metre a frame at most');
      expect(eye.y, closeTo(10.0, 1e-6), reason: 'up where it looks from');

      game.camera.stop();
      game.camera.setBounds(Rectangle.fromLTRB(-5.0, -5.0, 5.0, 5.0));
      game.camera.moveTo(Vector2(40.0, 0.0));
      for (var i = 0; i < 3; i++) {
        game.update(1 / 60);
      }
      expect(camera.readPosition().x, closeTo(5.0, 1e-6));
    },
  );
}

final class _Jumper extends PositionComponent {}

final class _Runner extends PositionComponent {
  @override
  void update(double dt) {
    super.update(dt);
    position.x += 10.0;
  }
}
