import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _HasCollidablesGame extends FlameGame with HasCollidables {}

class _TestBlock extends PositionComponent with HasHitboxes, Collidable {
  final List<Collidable> collisions = List.empty(growable: true);

  _TestBlock(Vector2 position, Vector2 size, CollidableType type)
      : super(position: position, size: size) {
    collidableType = type;
    addHitbox(
      HitboxRectangle(),
    );
  }

  bool collidedWith(Collidable otherCollidable) {
    return collisions.contains(otherCollidable);
  }

  bool collidedWithAll(
    List<Collidable> otherCollidables, {
    bool containsSelf = true,
  }) {
    return collisions
            .toSet()
            .containsAll(otherCollidables.toList()..remove(this)) &&
        collisions.length == otherCollidables.length - (containsSelf ? 1 : 0);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    collisions.add(other);
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
      expect(blockA.collidedWith(blockB), true);
      expect(blockB.collidedWith(blockA), true);
      expect(blockA.collisions.length, 1);
      expect(blockB.collisions.length, 1);
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
      expect(blockA.collisions.isEmpty, true);
      expect(blockB.collisions.isEmpty, true);
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
      expect(blockA.collisions.isEmpty, true);
      expect(blockB.collisions.isEmpty, true);
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
      expect(blockA.collidedWith(blockB), true);
      expect(blockB.collidedWith(blockA), true);
      expect(blockA.collisions.length, 1);
      expect(blockB.collisions.length, 1);
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
      expect(blockA.collidedWith(blockB), true);
      expect(blockB.collidedWith(blockA), true);
      expect(blockA.collisions.length, 1);
      expect(blockB.collisions.length, 1);
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
      expect(blockA.collisions.length, 0);
      expect(blockB.collisions.length, 0);
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
      expect(blockA.collisions.length, 0);
      expect(blockB.collisions.length, 0);
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
      expect(blockA.collisions.length, 0);
      expect(blockB.collisions.length, 0);
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
      expect(blockA.collisions.length, 0);
      expect(blockB.collisions.length, 0);
    });

    withCollidables.test(
      'correct collisions with many involved collidables',
      (game) async {
        final actives = List.generate(
          100,
          (_) => _TestBlock(
            Vector2.random() - Vector2.random(),
            Vector2.all(10),
            CollidableType.active,
          ),
        );
        final statics = List.generate(
          100,
          (_) => _TestBlock(
            Vector2.random() - Vector2.random(),
            Vector2.all(10),
            CollidableType.passive,
          ),
        );
        final inactives = List.generate(
          100,
          (_) => _TestBlock(
            Vector2.random() - Vector2.random(),
            Vector2.all(10),
            CollidableType.inactive,
          ),
        );
        await game.ensureAddAll((actives + statics + inactives)..shuffle());
        game.update(0);
        expect(
          actives.fold<bool>(
            true,
            (hasCorrectCollisions, c) => c.collidedWithAll(actives + statics),
          ),
          true,
        );
        expect(
          statics.fold<bool>(
            true,
            (hasCorrectCollisions, c) =>
                c.collidedWithAll(actives, containsSelf: false),
          ),
          true,
        );
        expect(
          inactives.fold<bool>(
            true,
            (hasCorrectCollisions, c) => c.collisions.isEmpty,
          ),
          true,
        );
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
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.collidedWith(blockB), false);
      expect(blockB.collidedWith(blockA), false);
      expect(blockA.collisions.length, 0);
      expect(blockB.collisions.length, 0);
      blockA.scale = Vector2.all(2.0);
      game.update(0);
      expect(blockA.collidedWith(blockB), true);
      expect(blockB.collidedWith(blockA), true);
      expect(blockA.collisions.length, 1);
      expect(blockB.collisions.length, 1);
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
      expect(blockA.containsPoint(Vector2.all(11)), true);
    });

    withCollidables.test('detects collision on child components', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final innerBlockA = _TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        CollidableType.active,
      );
      blockA.add(innerBlockA);

      final blockB = _TestBlock(
        Vector2.all(5),
        Vector2.all(10),
        CollidableType.active,
      );
      final innerBlockB = _TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        CollidableType.active,
      );
      blockB.add(innerBlockB);

      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.collisions, <Collidable>[blockB, innerBlockB]);
      expect(blockB.collisions, <Collidable>[blockA, innerBlockA]);
      expect(innerBlockA.collisions, <Collidable>[blockB, innerBlockB]);
      expect(innerBlockB.collisions, <Collidable>[blockA, innerBlockA]);
    });
  });
}
