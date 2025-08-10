import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

void main() {
  group('Collision callbacks', () {
    runCollisionTestRegistry({
      'collidable callbacks are called': (game) async {
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
      },
      'collidable callbacks are called when removing a Collidable':
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
      'hitbox callbacks are called': (game) async {
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
      },
      'hitboxes are in any descendants': (game) async {
        // The hitboxParent of the `testHitbox` will be the `player`.
        final player = TestBlock(
          Vector2.all(0),
          Vector2.all(10),
          addTestHitbox: false,
          children: [
            Component(
              children: [
                Component(children: [TestHitbox()]),
              ],
            ),
          ],
        );
        final block = TestBlock(Vector2.all(100), Vector2.all(10));

        await game.ensureAddAll([player, block]);

        expect(block.startCounter, 0);
        expect(block.onCollisionCounter, 0);
        expect(block.endCounter, 0);

        // player <== collides with  ==> block
        block.position = Vector2.all(5);
        game.update(0);

        expect(block.startCounter, 1);
        expect(block.onCollisionCounter, 1);
        expect(block.endCounter, 0);
      },
      'hitboxParent is PositionComponent but not CollisionCallbacks':
          (game) async {
            final player = PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
              children: [
                Component(
                  children: [
                    Component(children: [TestHitbox()]),
                  ],
                ),
              ],
            );
            final block = TestBlock(Vector2.all(100), Vector2.all(10));

            await game.ensureAddAll([player, block]);

            block.position = Vector2.all(5);
            game.update(0);

            expect(block.startCounter, 1);
            expect(block.onCollisionCounter, 1);
            expect(block.endCounter, 0);
          },
    });
  });

  runCollisionTestRegistry({
    'hitbox callbacks are called when Collidable is removed': (game) async {
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
    'hitbox end callbacks are called when hitbox is moved away fast':
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
    'onCollisionEnd is only called when there previously was a collision':
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
    'callbacks are only called once for hitboxes on each other': (game) async {
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
    'callbacks return the parent of the composite hitbox on collisions':
        (game) async {
          final size = Vector2.all(10);
          final hitboxA = TestHitbox();
          final compositeA = CompositeTestHitbox(
            size: size,
            children: [hitboxA],
          );
          final blockA = TestBlock(
            Vector2.zero(),
            size,
            children: [compositeA],
            addTestHitbox: false,
          );
          final hitboxB = TestHitbox();
          final compositeB = CompositeTestHitbox(
            size: size,
            children: [hitboxB],
          );
          final blockB = TestBlock(
            Vector2.all(15),
            size,
            children: [compositeB],
            addTestHitbox: false,
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
          expect(blockA.collidingWith(blockB), isTrue);
          expect(blockB.collidingWith(blockA), isTrue);

          blockB.position.y += 20;
          game.update(0);
          expect(blockA.startCounter, 1);
          expect(blockB.startCounter, 1);
          expect(blockA.onCollisionCounter, 1);
          expect(blockB.onCollisionCounter, 1);
          expect(blockA.endCounter, 1);
          expect(blockB.endCounter, 1);
          expect(blockA.collidingWith(blockB), isFalse);
          expect(blockB.collidingWith(blockA), isFalse);
        },
    'end and start callbacks are only called once for hitboxes sharing a side':
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
    'component collision callbacks are not called with hitbox '
        'triggersParentCollision option': (game) async {
      final utilityHitboxA = TestHitbox('hitboxA')
        ..triggersParentCollision = false;
      final blockA = TestBlock(
        Vector2.all(10),
        Vector2.all(10),
      );
      blockA.add(utilityHitboxA);

      final utilityHitboxB = TestHitbox('hitboxB')
        ..triggersParentCollision = false;
      final blockB = TestBlock(
        Vector2.all(15),
        Vector2.all(10),
      );
      blockB.add(utilityHitboxB);
      await game.ensureAddAll([blockA, blockB]);

      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 1);
      expect(blockB.onCollisionCounter, 1);
      expect(blockA.endCounter, 0);
      expect(blockB.endCounter, 0);
      expect(utilityHitboxA.startCounter, 2);
      expect(utilityHitboxB.startCounter, 2);
      expect(utilityHitboxA.onCollisionCounter, 2);
      expect(utilityHitboxB.onCollisionCounter, 2);
      expect(utilityHitboxA.endCounter, 0);
      expect(utilityHitboxB.endCounter, 0);

      blockB.position = Vector2(30, 30);
      game.update(0);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 1);
      expect(blockB.onCollisionCounter, 1);
      expect(blockA.endCounter, 1);
      expect(blockB.endCounter, 1);
      expect(utilityHitboxA.startCounter, 2);
      expect(utilityHitboxB.startCounter, 2);
      expect(utilityHitboxA.onCollisionCounter, 2);
      expect(utilityHitboxB.onCollisionCounter, 2);
      expect(utilityHitboxA.endCounter, 2);
      expect(utilityHitboxB.endCounter, 2);
    },

    // Reproduced #1478
    'collision callbacks with many hitboxes added': (game) async {
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
    // Reproduced #1478
    'collision callbacks with changed game size': (collisionSystem) async {
      final game = collisionSystem as FlameGame;
      final block = TestBlock(Vector2.all(20), Vector2.all(10))
        ..anchor = Anchor.center;
      final screenHitbox = ScreenHitbox();
      game.world.addAll([block, screenHitbox]);
      await game.ready();
      game.world.update(0);

      game.update(0);
      expect(block.startCounter, 0);
      expect(block.onCollisionCounter, 0);
      expect(block.endCounter, 0);
      block.position.x = game.size.x / 2;

      game.update(0);
      expect(block.startCounter, 1);
      expect(block.onCollisionCounter, 1);
      expect(block.endCounter, 0);
      game.onGameResize(game.size * 2);

      game.update(0);
      expect(block.startCounter, 1);
      expect(block.onCollisionCounter, 1);
      expect(block.endCounter, 1);
      block.position.y = game.size.y / 2;

      game.update(0);
      expect(block.startCounter, 2);
      expect(block.onCollisionCounter, 2);
      expect(block.endCounter, 1);
    },
    'collision callbacks for solid hitbox': (game) async {
      final innerBlock = TestBlock(Vector2.zero(), Vector2.all(2))
        ..anchor = Anchor.center
        ..hitbox.isSolid = true;
      final outerBlock = TestBlock(Vector2.zero(), Vector2.all(4))
        ..anchor = Anchor.center
        ..hitbox.isSolid = true;
      await game.ensureAddAll([innerBlock, outerBlock]);

      game.update(0);
      expect(innerBlock.startCounter, 1);
      expect(innerBlock.onCollisionCounter, 1);
      expect(innerBlock.endCounter, 0);

      innerBlock.position = Vector2.all(5);
      game.update(0);

      expect(outerBlock.startCounter, 1);
      expect(outerBlock.onCollisionCounter, 1);
      expect(outerBlock.endCounter, 1);
    },
    'collision callbacks for nested World': (outerCollisionSystem) async {
      final game = outerCollisionSystem as FlameGame;
      final world1 = CollisionDetectionWorld();
      final world2 = CollisionDetectionWorld();
      final camera1 = CameraComponent(world: world1);
      final camera2 = CameraComponent(world: world2);
      await game.ensureAddAll([world1, world2, camera1, camera2]);
      final block1 = TestBlock(Vector2(1, 1), Vector2.all(2))
        ..anchor = Anchor.center;
      final block2 = TestBlock(Vector2(1, -1), Vector2.all(2))
        ..anchor = Anchor.center;
      final block3 = TestBlock(Vector2(-1, 1), Vector2.all(2))
        ..anchor = Anchor.center;
      final block4 = TestBlock(Vector2(-1, -1), Vector2.all(2))
        ..anchor = Anchor.center;
      await world1.ensureAddAll([block1, block2]);
      await world2.ensureAddAll([block3, block4]);

      game.update(0);
      for (final block in [block1, block2, block3, block4]) {
        expect(block.startCounter, 1);
        expect(block.onCollisionCounter, 1);
        expect(block.endCounter, 0);
      }
      expect(block1.collidedWithExactly([block2]), isTrue);
      expect(block2.collidedWithExactly([block1]), isTrue);
      expect(block3.collidedWithExactly([block4]), isTrue);
      expect(block4.collidedWithExactly([block3]), isTrue);

      for (final block in [block1, block2, block3, block4]) {
        block.position.scale(3);
      }

      game.update(0);
      for (final block in [block1, block2, block3, block4]) {
        expect(block.startCounter, 1);
        expect(block.onCollisionCounter, 1);
        expect(block.endCounter, 1);
      }
    },
  });

  group('ComponentTypeCheck(only supported in the QuadTree)', () {
    testQuadTreeCollisionDetectionGame(
      'makes the correct Component type start to collide',
      (game) async {
        final water = Water(
          position: Vector2.all(0),
          size: Vector2.all(10),
          children: [
            Component(
              children: [
                Component(children: [TestHitbox()]),
              ],
            ),
          ],
        );
        final brick = Brick(
          position: Vector2.all(50),
          size: Vector2.all(10),
          children: [
            Component(
              children: [
                Component(children: [TestHitbox()]),
              ],
            ),
          ],
        );

        final block = TestBlock(
          Vector2.all(100),
          Vector2.all(10),
          onComponentTypeCheck: (other) {
            if (other is Water) {
              return false;
            }
            return true;
          },
        );

        await game.ensureAddAll([water, brick, block]);

        // block <== collides with  ==> water
        // But as [TestBlock.onComponentTypeCheck] returns false with Water,
        // they do not actually start to collide.
        block.position = Vector2.all(5);
        game.update(0);

        expect(block.startCounter, 0);
        expect(block.onCollisionCounter, 0);
        expect(block.endCounter, 0);

        // block <== collides with  ==> brick
        block.position = Vector2.all(55);
        game.update(0);

        expect(block.startCounter, 1);
        expect(block.onCollisionCounter, 1);
        expect(block.endCounter, 0);
      },
    );
  });
}
