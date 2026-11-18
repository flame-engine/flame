import 'dart:math';

import 'package:flame/game.dart' show FlameGame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';

class _Group({
  super.position,
  super.children,
}) extends Component3D;

class _Box({super.position}) extends Object3D {
  @override
  Aabb3? computeLocalAabb() =>
      Aabb3.minMax(Vector3.all(-0.5), Vector3.all(0.5));

  @override
  void draw(RenderContext context) {}
}

/// The union of the bounds of the world's components but lights, computed
/// from scratch.
Aabb3? _bruteForce(World3D world) {
  Aabb3? union;
  for (final child in world.children) {
    if (child is Component3D && child is! LightComponent) {
      if (union == null) {
        union = Aabb3.copy(child.aabb);
      } else {
        union.hull(child.aabb);
      }
    }
  }
  return union;
}

void _expectExact(World3D world) {
  final expected = _bruteForce(world);
  final actual = world.sceneBounds;
  if (expected == null) {
    expect(actual, isNull);
    return;
  }
  expect(actual, isNotNull);
  expect(actual!.min, closeToVector3(expected.min, 1e-6));
  expect(actual.max, closeToVector3(expected.max, 1e-6));
}

FlameGame _game() => FlameGame(world: World3D());

void main() {
  group('World3D.sceneBounds', () {
    testWithGame('is null without components but lights', _game, (
      game,
    ) async {
      final world = game.world as World3D;
      expect(world.sceneBounds, isNull);
      await world.ensureAdd(LightComponent.point(position: Vector3.all(9)));
      expect(world.sceneBounds, isNull);
    });

    testWithGame('is the union of the components but lights', _game, (
      game,
    ) async {
      final world = game.world as World3D;
      await world.ensureAddAll([
        _Box(position: Vector3(1, 2, 3)),
        _Box(position: Vector3(-4, 0, 1)),
        LightComponent.point(position: Vector3.all(50)),
        _Group(
          position: Vector3(0, 10, 0),
          children: [_Box(position: Vector3(0, 0, -2))],
        ),
      ]);

      final bounds = world.sceneBounds!;
      expect(bounds.min, closeToVector3(Vector3(-4.5, -0.5, -2.5)));
      expect(bounds.max, closeToVector3(Vector3(1.5, 10.5, 3.5)));
    });

    testWithGame('follows moves, additions and removals exactly', _game, (
      game,
    ) async {
      final world = game.world as World3D;
      final random = Random(7);
      Vector3 randomPosition() => Vector3(
        random.nextDouble() * 20 - 10,
        random.nextDouble() * 20 - 10,
        random.nextDouble() * 4 - 2,
      );
      final leaves = <_Box>[];
      final groups = <_Group>[];
      for (var i = 0; i < 20; i++) {
        final leaf = _Box(position: randomPosition());
        leaves.add(leaf);
        final group = _Group(position: randomPosition(), children: [leaf]);
        groups.add(group);
      }
      await world.ensureAddAll(groups);
      _expectExact(world);

      for (var step = 0; step < 300; step++) {
        switch (random.nextInt(6)) {
          case 0:
            // A top-level component moves.
            groups[random.nextInt(groups.length)].position = randomPosition();
          case 1:
            // A nested one moves.
            leaves[random.nextInt(leaves.length)].position = randomPosition();
          case 2:
            // One grows.
            groups[random.nextInt(groups.length)].scale = Vector3.all(
              0.5 + random.nextDouble() * 2,
            );
          case 3:
            final leaf = _Box(position: randomPosition());
            leaves.add(leaf);
            final group = _Group(position: randomPosition(), children: [leaf]);
            groups.add(group);
            await world.ensureAdd(group);
          case 4:
            if (groups.length > 1) {
              final group = groups.removeAt(random.nextInt(groups.length));
              leaves.removeWhere(group.children.contains);
              group.removeFromParent();
              await game.ready();
            }
          case 5:
            // A child is added to a component of the world.
            final group = groups[random.nextInt(groups.length)];
            final leaf = _Box(position: randomPosition());
            leaves.add(leaf);
            await group.ensureAdd(leaf);
        }
        _expectExact(world);
      }
    });

    testWithGame('skips the components whose bounds did not change', _game, (
      game,
    ) async {
      final world = game.world as World3D;
      final boxes = [
        for (var i = 0; i < 100; i++)
          _Box(position: Vector3(i % 10 - 4.5, i ~/ 10 - 4.5, 0)),
      ];
      await world.ensureAddAll(boxes);
      final before = Aabb3.copy(world.sceneBounds!);

      // Inside the union: it does not change.
      boxes[44].position.setValues(0.2, 0.3, 0);
      expect(world.sceneBounds!.min, closeToVector3(before.min));
      expect(world.sceneBounds!.max, closeToVector3(before.max));

      // Out of it: it grows.
      boxes[44].position.setValues(20, 0, 0);
      expect(world.sceneBounds!.max.x, closeTo(20.5, 1e-6));

      // Back in: it shrinks again.
      boxes[44].position.setValues(0, 0, 0);
      expect(world.sceneBounds!.max, closeToVector3(before.max));
    });

    testWithGame('costs little when few components move', _game, (
      game,
    ) async {
      final world = game.world as World3D;
      final boxes = [
        for (var i = 0; i < 600; i++)
          _Box(position: Vector3(i % 30 - 15, i ~/ 30 - 10, 0)),
      ];
      await world.ensureAddAll(boxes);
      world.sceneBounds;

      double microsecondsPerRead(
        void Function(int frame) move,
        Object? Function() read,
      ) {
        const frames = 400;
        final stopwatch = Stopwatch();
        for (var frame = 0; frame < frames; frame++) {
          move(frame);
          stopwatch.start();
          read();
          stopwatch.stop();
        }
        return stopwatch.elapsedMicroseconds / frames;
      }

      void moveAll(int frame) {
        for (final (i, box) in boxes.indexed) {
          box.position.x = i % 30 - 15 + 0.1 * ((frame + i) % 3);
        }
      }

      void moveFew(int frame) {
        for (var i = 0; i < 6; i++) {
          boxes[100 + i * 50].position.y = i - 3 + 0.1 * (frame % 3);
        }
      }

      final staticRead = microsecondsPerRead((_) {}, () => world.sceneBounds);
      final fewRead = microsecondsPerRead(moveFew, () => world.sceneBounds);
      final fewWalk = microsecondsPerRead(moveFew, () => _bruteForce(world));
      final allRead = microsecondsPerRead(moveAll, () => world.sceneBounds);
      final allWalk = microsecondsPerRead(moveAll, () => _bruteForce(world));
      debugPrint(
        'Scene bounds of 600 components, us per frame on this machine: '
        'static ${staticRead.toStringAsFixed(2)}, '
        '6 moving ${fewRead.toStringAsFixed(2)} '
        '(walk ${fewWalk.toStringAsFixed(2)}), '
        'all moving ${allRead.toStringAsFixed(2)} '
        '(walk ${allWalk.toStringAsFixed(2)})',
      );
      _expectExact(world);
      // Without changes, reading it visits nothing.
      expect(staticRead, lessThan(fewWalk));
    });
  });

  test('a component is removed from its set of bounds', () {
    final bounds = ComponentBounds();
    final box = _Box(position: Vector3(1, 1, 1));
    bounds.add(box);
    expect(bounds.value!.center, closeToVector3(Vector3(1, 1, 1)));
    bounds.remove(box);
    expect(bounds.value, isNull);
    // Moving it no longer concerns the set.
    box.position.setValues(5, 5, 5);
    expect(bounds.value, isNull);
    expect(bounds.length, 0);
  });
}
