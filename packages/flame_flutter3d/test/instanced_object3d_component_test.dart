/// Many small Flame components of one shape drawn as one batch: a slot each
/// while mounted, the Flame transform written into it, the slot given back
/// when the component goes.
library;

import 'package:flame/components.dart' show Component;
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart';
import 'package:flutter_test/flutter_test.dart';

InstancedMeshNode _batch() => InstancedMeshNode(
  CpuMesh(CuboidShape(size: Vector3.all(1.0)).build()),
  Material(),
  capacity: 4,
);

Vector3 _placeOf(InstancedMeshNode batch, int index) {
  final m = Matrix4.zero();
  batch.readTransform(index, m);
  return m.getTranslation();
}

void main() {
  testWithGame<FlameGame>(
    'each mounted component draws through a slot at its place',
    FlameGame.new,
    (game) async {
      final batch = _batch();
      final shots = <InstancedObject3dComponent>[
        for (var i = 0; i < 3; i++)
          InstancedObject3dComponent(
            batch: batch,
            plane: BridgePlane.ground(),
            elevation: 1.5,
            position: Vector2(i.toDouble(), -10.0),
          ),
      ];
      game.addAll(shots);
      await game.ready();
      expect(batch.count, 3);

      shots[2].position.y = -20.0;
      game.update(1 / 60);
      final third = _placeOf(batch, shots[2].slot!.index);
      expect(third.x, closeTo(2.0, 1e-6));
      expect(third.y, closeTo(1.5, 1e-6));
      expect(third.z, closeTo(-20.0, 1e-6));
    },
  );

  testWithGame<FlameGame>(
    'a removed component gives its slot back at once, and the others keep '
    'theirs',
    FlameGame.new,
    (game) async {
      final batch = _batch();
      final first = InstancedObject3dComponent(
        batch: batch,
        plane: BridgePlane.ground(),
        position: Vector2(1.0, 0.0),
      );
      final last = InstancedObject3dComponent(
        batch: batch,
        plane: BridgePlane.ground(),
        position: Vector2(5.0, 0.0),
      );
      game.addAll(<InstancedObject3dComponent>[first, last]);
      await game.ready();

      first.removeFromParent();
      expect(batch.count, 1, reason: 'not drawn in the frame it went');
      await game.ready();
      expect(batch.count, 1, reason: 'given back once, not twice');
      expect(_placeOf(batch, last.slot!.index).x, closeTo(5.0, 1e-6));
    },
  );

  testWithGame<FlameGame>('a hidden component draws nothing', FlameGame.new, (
    game,
  ) async {
    final batch = _batch();
    final blinking = InstancedObject3dComponent(
      batch: batch,
      plane: BridgePlane.ground(),
      position: Vector2(3.0, 0.0),
    );
    game.add(blinking);
    await game.ready();

    blinking.isVisible = false;
    game.update(1 / 60);
    final m = Matrix4.identity();
    batch.readTransform(blinking.slot!.index, m);
    expect(m.getMaxScaleOnAxis(), 0.0);

    blinking.isVisible = true;
    game.update(1 / 60);
    expect(_placeOf(batch, blinking.slot!.index).x, closeTo(3.0, 1e-6));
  });

  testWithGame<FlameGame>(
    'a still instance leaves its batch unchanged, and a moved one does not',
    FlameGame.new,
    (game) async {
      // Mutation: write the slot whether or not the component moved.
      final batch = _batch();
      final shot = InstancedObject3dComponent(
        batch: batch,
        plane: BridgePlane.ground(),
        position: Vector2(1.0, 0.0),
      );
      game.add(shot);
      await game.ready();
      game.update(1 / 60);

      final version = batch.dataVersion;
      game.update(1 / 60);
      game.update(1 / 60);
      expect(batch.dataVersion, version);

      shot.position.y = -5.0;
      game.update(1 / 60);
      expect(batch.dataVersion, greaterThan(version));
      expect(_placeOf(batch, shot.slot!.index).z, closeTo(-5.0, 1e-6));
    },
  );

  testWithGame<FlameGame>(
    'an instance has a tint and an opacity of its own',
    FlameGame.new,
    (game) async {
      // A hit flash on one of many: the others keep their colour.
      //
      // Mutation: never write the slot's colour after it is taken.
      final batch = _batch();
      final a = InstancedObject3dComponent(
        batch: batch,
        plane: BridgePlane.ground(),
      );
      final b = InstancedObject3dComponent(
        batch: batch,
        plane: BridgePlane.ground(),
        position: Vector2(2.0, 0.0),
      );
      game.addAll(<Component>[a, b]);
      await game.ready();

      a.tint.setValues(1.0, 0.2, 0.2, 1.0);
      b.add(OpacityEffect.to(0.5, EffectController(duration: 0.1)));
      game.update(0.2);

      Vector4 colourOf(InstancedObject3dComponent c) {
        final at = c.slot!.index * InstancedMeshNode.floatsPerInstance + 12;
        final d = batch.instanceData;
        return Vector4(d[at], d[at + 1], d[at + 2], d[at + 3]);
      }

      expect(colourOf(a), Vector4(1.0, 0.2, 0.2, 1.0));
      expect(colourOf(b).w, closeTo(0.5, 1e-6));
      expect(colourOf(b).x, 1.0, reason: 'only faded, not tinted');
    },
  );
}
