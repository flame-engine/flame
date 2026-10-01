/// Meshes a bridged component made for itself, let go when it goes.
library;

import 'package:flame/components.dart' show Component, PositionComponent;
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart';
import 'package:flutter3d_hardware/testing.dart';
import 'package:flutter_test/flutter_test.dart';

final class _World extends FlameGame with HasFlutter3d {}

void main() {
  test(
    'a removed component gives its own meshes back, and no others',
    () async {
      // A bridge's span, built for it, left on the device after the bridge was
      // gone: each stretch of river leaked one.
      //
      // Mutation: let nothing go on removal.
      final device = FakeBackend();
      final game = _World()..open3d(device);
      await initializeGame(() => game);
      final span = DeviceMesh.upload(
        device,
        CuboidShape(size: Vector3.all(1.0)).build(),
      );
      final shared = DeviceMesh.upload(
        device,
        CuboidShape(size: Vector3.all(1.0)).build(),
      );
      final bridge = Object3dComponent(
        node: MeshNode(span, Material()),
        scene: game.scene,
        plane: BridgePlane.ground(),
        owns: <DeviceMesh>[span],
      );
      game.add(bridge);
      await game.ready();
      expect(device.releasedGeometry, isEmpty);

      bridge.removeFromParent();
      await game.ready();
      await Future<void>.delayed(Duration.zero);
      expect(
        device.releasedGeometry,
        containsAll(<GeometryBuffer>[span.vertices, span.indices]),
      );
      expect(device.releasedGeometry, isNot(contains(shared.vertices)));
    },
  );

  test('a component moved to another parent keeps its meshes', () async {
    // Flame moves a component by removing it and mounting it again, and
    // the removal let its meshes go while it went on drawing them.
    //
    // Mutation: let them go in onRemove, at once.
    final device = FakeBackend();
    final game = _World()..open3d(device);
    await initializeGame(() => game);
    final hull = DeviceMesh.upload(
      device,
      CuboidShape(size: Vector3.all(1.0)).build(),
    );
    final raft = Object3dComponent(
      node: MeshNode(hull, Material()),
      scene: game.scene,
      plane: BridgePlane.ground(),
      owns: <DeviceMesh>[hull],
    );
    final log = PositionComponent();
    game.addAll(<Component>[raft, log]);
    await game.ready();

    raft.parent = log;
    await game.ready();
    await Future<void>.delayed(Duration.zero);
    expect(raft.isMounted, isTrue);
    expect(raft.parent, same(log));
    expect(device.releasedGeometry, isEmpty);
    expect(raft.node.parent, isNotNull, reason: 'still in the scene');
  });
}
