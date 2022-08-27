import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

void main() {
  group('Collision callbacks', () {
    testCollisionDetectionGame('collidable callbacks are called', (game) async {
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

    testCollisionDetectionGame(
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

    testCollisionDetectionGame('hitbox callbacks are called', (game) async {
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

  testCollisionDetectionGame(
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

  testCollisionDetectionGame(
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

  testCollisionDetectionGame(
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

  testCollisionDetectionGame(
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

  testCollisionDetectionGame(
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

  // Reproduced #1478
  testCollisionDetectionGame(
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
        expect(player.endCounter, 0);
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
  );

  // Reproduced #1478
  testCollisionDetectionGame(
    'collision callbacks with changed game size',
    (game) async {
      final block = TestBlock(Vector2.all(20), Vector2.all(10))
        ..anchor = Anchor.center;
      await game.ensureAddAll([ScreenHitbox(), block]);

      game.update(0);
      expect(block.startCounter, 0);
      expect(block.onCollisionCounter, 0);
      expect(block.endCounter, 0);
      block.position.x = game.size.x;

      game.update(0);
      expect(block.startCounter, 1);
      expect(block.onCollisionCounter, 1);
      expect(block.endCounter, 0);
      game.onGameResize(game.size * 2);

      game.update(0);
      expect(block.startCounter, 1);
      expect(block.onCollisionCounter, 1);
      expect(block.endCounter, 1);
      block.position.y = game.size.y;

      game.update(0);
      expect(block.startCounter, 2);
      expect(block.onCollisionCounter, 2);
      expect(block.endCounter, 1);
    },
  );
}
