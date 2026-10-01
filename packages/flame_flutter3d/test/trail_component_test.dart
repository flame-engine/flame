/// A line drawn behind a bridged missile, gone with it.
library;

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_hardware/testing.dart';
import 'package:flutter_test/flutter_test.dart';

final class _World extends FlameGame with HasFlutter3d {}

void main() {
  test(
    'a missile lays its trail as it flies, and takes it when it goes',
    () async {
      final device = FakeBackend();
      final game = _World()..open3d(device);
      await initializeGame(() => game);
      final trail = TrailComponent(spacing: 1.0, length: 4);
      final missile = Object3dComponent(
        node: SceneNode(),
        scene: game.scene,
        plane: BridgePlane.ground(),
        direction: SyncDirection.flameToScene,
      )..add(trail);
      game.add(missile);
      await game.ready();

      for (var i = 0; i < 10; i++) {
        missile.position.y -= 1.5;
        game.update(1 / 60);
      }
      final line = trail.line!;
      expect(line.count, 4, reason: 'a fixed length behind it');
      expect(line.points.last.z, closeTo(missile.position.y, 1.6));
      expect(game.scene.root.childrenView, contains(line));

      missile.removeFromParent();
      await game.ready();
      expect(game.scene.root.childrenView, isNot(contains(line)));
      expect(device.releasedGeometry, isNotEmpty);
    },
  );

  test('a jump across the world breaks the trail rather than drawing a line '
      'across it', () async {
    // Mutation: lay a point wherever the missile is, however far it went.
    final device = FakeBackend();
    final game = _World()..open3d(device);
    await initializeGame(() => game);
    final trail = TrailComponent(spacing: 1.0, length: 8)..breakAt = 5.0;
    final missile = Object3dComponent(
      node: SceneNode(),
      scene: game.scene,
      plane: BridgePlane.ground(),
      direction: SyncDirection.flameToScene,
    )..add(trail);
    game.add(missile);
    await game.ready();
    for (var i = 0; i < 3; i++) {
      missile.position.x += 1.5;
      game.update(1 / 60);
    }
    missile.position.x = -40.0;
    game.update(1 / 60);
    final points = trail.line!.points;
    expect(points, hasLength(1));
    expect(points.single.x, closeTo(-40.0, 1e-6));
  });

  test('resized, the line is widened against the new size', () async {
    // Mutation: tell the line the size once, on mount.
    final device = FakeBackend();
    final game = _World()..open3d(device);
    await initializeGame(() => game);
    final trail = TrailComponent();
    final missile = Object3dComponent(
      node: SceneNode(),
      scene: game.scene,
      plane: BridgePlane.ground(),
    )..add(trail);
    game.add(missile);
    await game.ready();

    game.onGameResize(Vector2(1024.0, 512.0));
    final viewport = trail.line!.material.polylineViewport!;
    expect(viewport[0], 1024.0);
    expect(viewport[1], 512.0);
  });
}
