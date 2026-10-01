/// A shield in the game: hit where a block is, it wears away and is drawn
/// again; through a hole, the shot passes.
library;

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d_hardware/testing.dart';
import 'package:flutter_test/flutter_test.dart';

final class _World extends FlameGame with HasFlutter3d {}

void main() {
  test('a hit on a block wears it away, and a hole lets a shot by', () async {
    // Mutation: report a hit wherever the shield's box is.
    final device = FakeBackend();
    final game = _World()..open3d(device);
    await initializeGame(() => game);
    final shield = CellGridComponent(
      grid: CellGrid.fromMask(<String>['####', '#..#']),
      device: device,
      scene: game.scene,
      plane: BridgePlane.ground(),
      material: engine.Material(),
      position: Vector2(10.0, -5.0),
    );
    game.add(shield);
    await game.ready();
    expect(shield.size, Vector2(4.0, 2.0));

    // The hole is the middle of the bottom row: one metre in, one and a
    // half down from the corner.
    expect(shield.hitAt(Vector2(11.5, -3.5), radius: 0.4), isFalse);
    expect(device.releasedGeometry, isEmpty);

    expect(shield.hitAt(Vector2(10.5, -4.5), radius: 0.4), isTrue);
    expect(shield.grid.isAlive(0, 0), isFalse);
    expect(device.releasedGeometry, isNotEmpty, reason: 'the old mesh went');
  });

  test('a removed shield gives back the mesh it was standing in', () async {
    // Mutation: let go of meshes only on a hit.
    final device = FakeBackend();
    final game = _World()..open3d(device);
    await initializeGame(() => game);
    final shield = CellGridComponent(
      grid: CellGrid.fromMask(<String>['##']),
      device: device,
      scene: game.scene,
      plane: BridgePlane.ground(),
      material: engine.Material(),
    );
    game.add(shield);
    await game.ready();
    final standing = shield.node.childrenView.whereType<MeshNode>().single;

    shield.removeFromParent();
    await game.ready();
    await Future<void>.delayed(Duration.zero);
    final mesh = standing.mesh as DeviceMesh;
    expect(
      device.releasedGeometry,
      containsAll(<GeometryBuffer>[mesh.vertices, mesh.indices]),
    );
  });
}
