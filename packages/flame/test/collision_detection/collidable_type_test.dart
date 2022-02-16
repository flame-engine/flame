import 'dart:math';

import 'package:flame/collision_detection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _HasCollidablesGame extends FlameGame with HasCollisionDetection {}

class _TestBlock extends PositionComponent
    with CollisionCallbacks<PositionComponent> {
  late final HitboxRectangle hitbox;
  String? name;

  _TestBlock(Vector2 position, Vector2 size, CollidableType type, {this.name})
      : super(position: position, size: size) {
    children.register<HitboxShape>();
    hitbox = HitboxRectangle()..collidableType = type;
    add(hitbox);
  }

  bool collidedWithExactly(List<CollisionCallbacks> collidables) {
    final otherCollidables = collidables.toSet()..remove(this);
    return activeCollisions.containsAll(otherCollidables) &&
        otherCollidables.containsAll(activeCollisions);
  }

  @override
  String toString() {
    return name == null
        ? '_TestBlock[${identityHashCode(this)}]'
        : '_TestBlock[$name]';
  }

  Set<Vector2> intersections(_TestBlock other) {
    final result = <Vector2>{};
    for (final hitboxA in children.query<HitboxShape>()) {
      for (final hitboxB in other.children.query<HitboxShape>()) {
        result.addAll(hitboxA.intersections(hitboxB));
      }
    }
    return result;
  }
}

void main() {
  final withCollidables = FlameTester(() => _HasCollidablesGame());

  group('Varying CollisionType', () {
    withCollidables.test('actives do collide', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.collidingWith(blockB), true);
      expect(blockB.collidingWith(blockA), true);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    withCollidables.test('sensors do not collide', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.passive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.isEmpty, true);
      expect(blockB.activeCollisions.isEmpty, true);
    });

    withCollidables.test('inactives do not collide', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.inactive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.isEmpty, true);
      expect(blockB.activeCollisions.isEmpty, true);
    });

    withCollidables.test('active collides with static', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.collidingWith(blockB), true);
      expect(blockB.collidingWith(blockA), true);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    withCollidables.test('sensor collides with active', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.passive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.collidingWith(blockB), true);
      expect(blockB.collidingWith(blockA), true);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    withCollidables.test('sensor does not collide with inactive', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.passive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    withCollidables.test('inactive does not collide with static', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.inactive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    withCollidables.test('active does not collide with inactive', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    withCollidables.test('inactive does not collide with active', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.inactive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    withCollidables.test(
      'correct collisions with many involved collidables',
      (game) async {
        final rng = Random(0);
        List<_TestBlock> generateBlocks(CollidableType type) {
          return List.generate(
            100,
            (_) => _TestBlock(
              Vector2.random(rng) - Vector2.random(rng),
              Vector2.all(10),
              type,
            ),
          );
        }

        final actives = generateBlocks(CollidableType.active);
        final passives = generateBlocks(CollidableType.passive);
        final inactives = generateBlocks(CollidableType.inactive);
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

    withCollidables.test('detects collision after scale', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = _TestBlock(
        Vector2.all(11),
        Vector2.all(10),
        CollidableType.active,
      );
      expect(blockA.collidingWith(blockB), isFalse);
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collidingWith(blockB), isFalse);
      game.update(0);
      print(blockA.intersections(blockB));
      print(game.collisionDetection.items);
      print(blockA.absoluteTopLeftPosition);
      print(blockB.absoluteTopLeftPosition);
      print(blockA.hitbox.absoluteTopLeftPosition);
      print(blockB.hitbox.absoluteTopLeftPosition);
      print(blockA.hitbox.size);
      print(blockB.hitbox.size);
      print(blockA.hitbox.vertices);
      print(blockB.hitbox.vertices);
      print(blockA.hitbox.absoluteScale);
      print(blockB.hitbox.absoluteScale);
      print(blockA.hitbox.globalVertices());
      print(blockB.hitbox.globalVertices());
      expect(blockA.collidingWith(blockB), isFalse);
      expect(blockB.collidingWith(blockA), isFalse);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
      blockA.scale = Vector2.all(2.0);
      game.update(0);
      print(blockA.hitbox.globalVertices());
      print(blockB.hitbox.globalVertices());
      expect(blockA.collidingWith(blockB), isTrue);
      expect(blockB.collidingWith(blockA), isTrue);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    withCollidables.test('testPoint detects point after scale', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAdd(blockA);
      game.update(0);
      expect(blockA.containsPoint(Vector2.all(11)), false);
      blockA.scale = Vector2.all(2.0);
      game.update(0);
      print(blockA.hitbox.absoluteScale);
      print(blockA.hitbox.globalVertices());
      expect(blockA.containsPoint(Vector2.all(11)), true);
    });

    withCollidables.test('detects collision on child components', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
        name: 'A',
      );
      final innerBlockA = _TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        CollidableType.active,
        name: 'iA',
      );
      blockA.add(innerBlockA);

      final blockB = _TestBlock(
        Vector2.all(5),
        Vector2.all(10),
        CollidableType.active,
        name: 'B',
      );
      final innerBlockB = _TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        CollidableType.active,
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
