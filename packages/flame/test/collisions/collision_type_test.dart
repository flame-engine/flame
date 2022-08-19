import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

void main() {
  group('CollisionType', () {
    testCollisionDetectionGame('actives do collide', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.collidingWith(blockB), true);
      expect(blockB.collidingWith(blockA), true);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    testCollisionDetectionGame('passives do not collide', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        type: CollisionType.passive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        type: CollisionType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.isEmpty, true);
      expect(blockB.activeCollisions.isEmpty, true);
    });

    testCollisionDetectionGame('inactives do not collide', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        type: CollisionType.inactive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        type: CollisionType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.isEmpty, true);
      expect(blockB.activeCollisions.isEmpty, true);
    });

    testCollisionDetectionGame('active collides with static', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        type: CollisionType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.collidingWith(blockB), true);
      expect(blockB.collidingWith(blockA), true);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    testCollisionDetectionGame('passive collides with active', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        type: CollisionType.passive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.collidingWith(blockB), true);
      expect(blockB.collidingWith(blockA), true);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    testCollisionDetectionGame('passive does not collide with inactive',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        type: CollisionType.passive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        type: CollisionType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    testCollisionDetectionGame('inactive does not collide with static',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        type: CollisionType.inactive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        type: CollisionType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    testCollisionDetectionGame('active does not collide with inactive',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        type: CollisionType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    testCollisionDetectionGame('inactive does not collide with active',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        type: CollisionType.inactive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    testCollisionDetectionGame(
      'correct collisions with many involved collidables',
      (game) async {
        final rng = Random(0);
        List<TestBlock> generateBlocks(CollisionType type) {
          return List.generate(
            100,
            (_) => TestBlock(
              Vector2.random(rng) - Vector2.random(rng),
              Vector2.all(10),
              type: type,
            ),
          );
        }

        final actives = generateBlocks(CollisionType.active);
        final passives = generateBlocks(CollisionType.passive);
        final inactives = generateBlocks(CollisionType.inactive);
        await game.ensureAddAll((actives + passives + inactives)..shuffle());
        game.update(0);
        expect(
          actives.every((c) => c.collidedWithExactly(actives + passives)),
          isTrue,
        );
        expect(passives.every((c) => c.collidedWithExactly(actives)), isTrue);
        expect(inactives.every((c) => c.activeCollisions.isEmpty), isTrue);
      },
    );

    testCollisionDetectionGame('detects collision after scale', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(11),
        Vector2.all(10),
      );
      expect(blockA.collidingWith(blockB), isFalse);
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collidingWith(blockB), isFalse);
      game.update(0);
      expect(blockA.collidingWith(blockB), isFalse);
      expect(blockB.collidingWith(blockA), isFalse);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
      blockA.scale = Vector2.all(2.0);
      game.update(0);
      expect(blockA.collidingWith(blockB), isTrue);
      expect(blockB.collidingWith(blockA), isTrue);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    testCollisionDetectionGame('detects collision after flip', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2(11, 0),
        Vector2.all(10),
      );
      expect(blockA.collidingWith(blockB), isFalse);
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collidingWith(blockB), isFalse);
      game.update(0);
      expect(blockA.collidingWith(blockB), isFalse);
      expect(blockB.collidingWith(blockA), isFalse);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
      blockB.flipHorizontally();
      game.update(0);
      expect(blockA.collidingWith(blockB), isTrue);
      expect(blockB.collidingWith(blockA), isTrue);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    testCollisionDetectionGame('detects collision after scale', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(11),
        Vector2.all(10),
      );
      expect(blockA.collidingWith(blockB), isFalse);
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collidingWith(blockB), isFalse);
      game.update(0);
      expect(blockA.collidingWith(blockB), isFalse);
      expect(blockB.collidingWith(blockA), isFalse);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
      blockA.scale = Vector2.all(2.0);
      game.update(0);
      expect(blockA.collidingWith(blockB), isTrue);
      expect(blockB.collidingWith(blockA), isTrue);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    testCollisionDetectionGame('testPoint detects point after flip',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      await game.ensureAdd(blockA);
      game.update(0);
      expect(blockA.containsPoint(Vector2(-1, 1)), false);
      blockA.flipHorizontally();
      game.update(0);
      expect(blockA.containsPoint(Vector2(-1, 1)), true);
    });

    testCollisionDetectionGame('testPoint detects point after scale',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      await game.ensureAdd(blockA);
      game.update(0);
      expect(blockA.containsPoint(Vector2.all(11)), false);
      blockA.scale = Vector2.all(2.0);
      game.update(0);
      expect(blockA.containsPoint(Vector2.all(11)), true);
    });

    testCollisionDetectionGame('detects collision on child components',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        name: 'A',
      );
      final innerBlockA = TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        name: 'iA',
      );
      blockA.add(innerBlockA);

      final blockB = TestBlock(
        Vector2.all(5),
        Vector2.all(10),
        name: 'B',
      );
      final innerBlockB = TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        name: 'iB',
      );
      blockB.add(innerBlockB);

      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions, {blockB, innerBlockB});
      expect(blockB.activeCollisions, {blockA, innerBlockA});
      expect(innerBlockA.activeCollisions, {blockB, innerBlockB});
      expect(innerBlockB.activeCollisions, {blockA, innerBlockA});
    });
  });
}
