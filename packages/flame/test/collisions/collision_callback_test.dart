import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

void main() {
  group('Collision callbacks', () {
    withCollidables.test('collidable callbacks are called', (game) async {
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
      expect(blockA.collidingWith(blockB), isTrue);
      expect(blockB.collidingWith(blockA), isTrue);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 1);
      expect(blockB.onCollisionCounter, 1);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);
      game.update(0);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 2);
      expect(blockB.onCollisionCounter, 2);
      blockB.position = Vector2.all(21);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);
      game.update(0);
      expect(blockA.collidingWith(blockB), isFalse);
      expect(blockB.collidingWith(blockA), isFalse);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
      game.update(0);
      expect(blockA.endCounter, 1);
      expect(blockB.endCounter, 1);
    });

    withCollidables.test(
      'collidable callbacks are called when removing a Collidable',
      (game) async {
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
        game.remove(blockA);
        game.update(0);
        expect(blockA.endCounter, 1);
        expect(blockB.endCounter, 1);
        expect(blockA.collidingWith(blockB), false);
        expect(blockB.collidingWith(blockA), false);
        expect(blockA.activeCollisions.length, 0);
        expect(blockB.activeCollisions.length, 0);
      },
    );

    withCollidables.test('hitbox callbacks are called', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
      );
      final hitboxA = blockA.hitbox;
      final hitboxB = blockB.hitbox;
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(hitboxA.collidingWith(hitboxB), true);
      expect(hitboxB.collidingWith(hitboxA), true);
      expect(hitboxA.activeCollisions.length, 1);
      expect(hitboxB.activeCollisions.length, 1);
      expect(hitboxA.startCounter, 1);
      expect(hitboxB.startCounter, 1);
      expect(hitboxA.onCollisionCounter, 1);
      expect(hitboxB.onCollisionCounter, 1);
      game.update(0);
      expect(hitboxA.startCounter, 1);
      expect(hitboxB.startCounter, 1);
      expect(hitboxA.onCollisionCounter, 2);
      expect(hitboxB.onCollisionCounter, 2);
      blockB.position = Vector2.all(21);
      expect(hitboxA.endCounter, 0);
      expect(hitboxB.endCounter, 0);
      game.update(0);
      expect(hitboxA.collidingWith(hitboxB), false);
      expect(hitboxB.collidingWith(hitboxA), false);
      expect(hitboxA.activeCollisions.length, 0);
      expect(hitboxB.activeCollisions.length, 0);
      expect(hitboxA.endCounter, 1);
      expect(hitboxB.endCounter, 1);
    });
  });

  withCollidables.test(
    'hitbox callbacks are called when Collidable is removed',
    (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
      );
      final hitboxA = blockA.hitbox;
      final hitboxB = blockB.hitbox;
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(hitboxA.collidingWith(hitboxB), true);
      expect(hitboxB.collidingWith(hitboxA), true);
      expect(hitboxA.activeCollisions.length, 1);
      expect(hitboxB.activeCollisions.length, 1);
      game.remove(blockA);
      game.update(0);
      expect(hitboxA.collidingWith(hitboxB), false);
      expect(hitboxB.collidingWith(hitboxA), false);
      expect(hitboxA.activeCollisions.length, 0);
      expect(hitboxB.activeCollisions.length, 0);
      expect(hitboxA.endCounter, 1);
      expect(hitboxB.endCounter, 1);
    },
  );

  withCollidables.test(
    'hitbox end callbacks are called when hitbox is moved away fast',
    (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
      );
      final hitboxA = blockA.hitbox;
      final hitboxB = blockB.hitbox;
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(hitboxA.collidingWith(hitboxB), true);
      expect(hitboxB.collidingWith(hitboxA), true);
      expect(hitboxA.activeCollisions.length, 1);
      expect(hitboxB.activeCollisions.length, 1);
      blockB.position = Vector2.all(1000);
      game.update(0);
      expect(hitboxA.collidingWith(hitboxB), false);
      expect(hitboxB.collidingWith(hitboxA), false);
      expect(hitboxA.activeCollisions.length, 0);
      expect(hitboxB.activeCollisions.length, 0);
      expect(hitboxA.endCounter, 1);
      expect(hitboxB.endCounter, 1);
    },
  );

  withCollidables.test(
    'onCollisionEnd is only called when there previously was a collision',
    (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2(5, 11),
        Vector2.all(10),
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      blockB.position.x += 2 * blockA.size.x;
      game.update(0);
      expect(blockA.startCounter, 0);
      expect(blockB.startCounter, 0);
      expect(blockA.onCollisionCounter, 0);
      expect(blockB.onCollisionCounter, 0);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);
    },
  );

  withCollidables.test(
    'callbacks are only called once for hitboxes on each other',
    (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(100),
        Vector2.all(10),
      );
      await game.ensureAddAll([blockA, blockB]);

      game.update(0);
      expect(blockA.startCounter, 0);
      expect(blockB.startCounter, 0);
      expect(blockA.onCollisionCounter, 0);
      expect(blockB.onCollisionCounter, 0);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);

      blockB.position = Vector2.all(5);
      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 1);
      expect(blockB.onCollisionCounter, 1);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);

      blockB.position = blockA.position;
      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 2);
      expect(blockB.onCollisionCounter, 2);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);

      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 3);
      expect(blockB.onCollisionCounter, 3);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);

      blockB.position.y += 20;
      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 3);
      expect(blockB.onCollisionCounter, 3);
      expect(blockA.endCounter, 1);
      expect(blockB.endCounter, 1);
    },
  );

  withCollidables.test(
    'end and start callbacks are only called once for hitboxes sharing a side',
    (game) async {
      final blockA = TestBlock(
        Vector2.all(10),
        Vector2.all(10),
      );
      final blockB = TestBlock(
        Vector2.all(21),
        Vector2.all(12),
      );
      await game.ensureAddAll([blockA, blockB]);

      game.update(0);
      expect(blockA.startCounter, 0);
      expect(blockB.startCounter, 0);
      expect(blockA.onCollisionCounter, 0);
      expect(blockB.onCollisionCounter, 0);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);

      blockB.position = Vector2(10, 14);
      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 1);
      expect(blockB.onCollisionCounter, 1);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);

      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 2);
      expect(blockB.onCollisionCounter, 2);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);

      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 3);
      expect(blockB.onCollisionCounter, 3);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);

      blockB.position =
          blockA.positionOfAnchor(Anchor.topRight) + Vector2(1, 0);
      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 3);
      expect(blockB.onCollisionCounter, 3);
      expect(blockA.endCounter, 1);
      expect(blockB.endCounter, 1);
    },
  );

  // Reproduces #1478, it creates many blocks lined up on the diagonal with one
  // empty space (one block-unit) between them. Then it moves another block so
  // that it starts colliding with one of the blocks, but for some reason the
  // collision is deemed to end in the same tick as it starts, which shouldn't
  // be possible. If you change the amount of blocks that are generated, this
  // will happen on different blocks (even though the blocks haven't moved).
  withCollidables.test(
    'collision callbacks with many hitboxes added',
    (game) async {
      const side = 10.0;
      final player = TestBlock(Vector2.zero(), Vector2.all(side))
        ..anchor = Anchor.center;
      await game.ensureAdd(player);

      final blocks = <PositionComponent>[];
      // Change 0 or 100 and there will be different blocks breaking
      const amount = 100;
      for (var id = 0; id < amount; id++) {
        final pos = 2 * id * side;
        final component = PositionComponent(
          position: Vector2.all(pos),
          size: Vector2.all(side),
          anchor: Anchor.center,
        )..add(RectangleHitbox());
        blocks.add(component);
      }
      await game.ensureAddAll(blocks);

      // All
      // amount = 33 - 2 bad
      // 10: [200.0,210.0]
      // 21: [420.0,430.0]

      // amount = 100 - 6 bad
      // 10: [200.0,210.0]
      // 21: [420.0,430.0]
      // 33: [660.0,670.0]
      // 66: [1320.0,1330.0]
      // 77: [1540.0,1550.0]
      // 88: [1760.0,1770.0]

      // amount = 1000 - 80 bad
      // 11: [220.0,230.0]
      // 24: [480.0,490.0]
      // 36: [720.0,730.0]
      // 49: [980.0,990.0]
      // 60: [1200.0,1210.0]
      // ...
      // 949: [18980.0,18990.0]
      // 962: [19240.0,19250.0]
      // 974: [19480.0,19490.0]
      // 987: [19740.0,19750.0]

      for (var i = 0; i < blocks.length; i++) {
        player.position = Vector2.all(-10000);
        game.update(0);
        final centerOfABlock = blocks[i].position;
        player.startCounter = 0;
        player.onCollisionCounter = 0;
        player.endCounter = 0;

        player.position = Vector2(
          centerOfABlock.x,
          centerOfABlock.y + 100,
        ); // no sides are overlaps
        game.update(0);
        expect(player.startCounter, 0);
        expect(player.onCollisionCounter, 0);
        expect(player.endCounter, 0);

        player.position = Vector2(
          centerOfABlock.x,
          centerOfABlock.y + 10,
        ); // two sides are overlaps

        game.update(0);
        expect(player.startCounter, 1);
        expect(player.onCollisionCounter, 1);
        if (player.endCounter != 0) {
          // Should not get in here since it can't both start and end
          // the same collision in the same tick.
          print('$i: ${player.position}');
        }
        //expect(player.endCounter, 0); // <---- this is the point that fails test
      }

      game.update(0);
      expect(player.startCounter, 1);
      expect(player.onCollisionCounter, 2);
      expect(player.endCounter, 0);

      game.update(0);
      expect(player.startCounter, 1);
      expect(player.onCollisionCounter, 3);
      expect(player.endCounter, 0);
    },
    skip: 'See issue #1478',
  );
}
