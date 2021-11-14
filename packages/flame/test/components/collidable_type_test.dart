import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

class HasCollidablesGame extends FlameGame with HasCollidables {}

class TestBlock extends PositionComponent with HasHitboxes, Collidable {
  final List<Collidable> collisions = List.empty(growable: true);

  TestBlock(Vector2 position, Vector2 size, CollidableType type)
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
  FlameTester withCollidables() {
    return FlameTester(
      () => HasCollidablesGame(),
    );
  }

  group('Varying CollisionType tests', () {
    withCollidables().test('Actives do collide', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collidedWith(blockB), true);
      expect(blockB.collidedWith(blockA), true);
      expect(blockA.collisions.length, 1);
      expect(blockB.collisions.length, 1);
    });

    withCollidables().test('Sensors do not collide', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.passive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.passive,
      );
      await game.addAll([blockA, blockB]);
      game.update(0);
      expect(blockA.collisions.isEmpty, true);
      expect(blockB.collisions.isEmpty, true);
    });

    withCollidables().test('Inactives do not collide', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.inactive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collisions.isEmpty, true);
      expect(blockB.collisions.isEmpty, true);
    });

    withCollidables().test('Active collides with static', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collidedWith(blockB), true);
      expect(blockB.collidedWith(blockA), true);
      expect(blockA.collisions.length, 1);
      expect(blockB.collisions.length, 1);
    });

    withCollidables().test('Sensor collides with active', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.passive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collidedWith(blockB), true);
      expect(blockB.collidedWith(blockA), true);
      expect(blockA.collisions.length, 1);
      expect(blockB.collisions.length, 1);
    });

    withCollidables().test('Sensor does not collide with inactive',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.passive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collisions.length, 0);
      expect(blockB.collisions.length, 0);
    });

    withCollidables().test('Inactive does not collide with static',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.inactive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collisions.length, 0);
      expect(blockB.collisions.length, 0);
    });

    withCollidables().test('Active does not collide with inactive',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collisions.length, 0);
      expect(blockB.collisions.length, 0);
    });

    withCollidables().test('Inactive does not collide with active',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.inactive,
      );
      final blockB = TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collisions.length, 0);
      expect(blockB.collisions.length, 0);
    });

    withCollidables().test(
      'Correct collisions with many involved collidables',
      (game) async {
        final actives = List.generate(
          100,
          (_) => TestBlock(
            Vector2.random() - Vector2.random(),
            Vector2.all(10),
            CollidableType.active,
          ),
        );
        final statics = List.generate(
          100,
          (_) => TestBlock(
            Vector2.random() - Vector2.random(),
            Vector2.all(10),
            CollidableType.passive,
          ),
        );
        final inactives = List.generate(
          100,
          (_) => TestBlock(
            Vector2.random() - Vector2.random(),
            Vector2.all(10),
            CollidableType.inactive,
          ),
        );
        await game.ensureAddAll((actives + statics + inactives)..shuffle());
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

    withCollidables().test('Detects collision after scale', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = TestBlock(
        Vector2.all(11),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
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

    withCollidables().test('TestPoint detects point after scale', (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAdd(blockA);
      expect(blockA.containsPoint(Vector2.all(11)), false);
      blockA.scale = Vector2.all(2.0);
      game.update(0);
      expect(blockA.containsPoint(Vector2.all(11)), true);
    });

    withCollidables().test('Detects collision on child components',
        (game) async {
      final blockA = TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final innerBlockA = TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        CollidableType.active,
      );
      blockA.add(innerBlockA);

      final blockB = TestBlock(
        Vector2.all(5),
        Vector2.all(10),
        CollidableType.active,
      );
      final innerBlockB = TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        CollidableType.active,
      );
      blockB.add(innerBlockB);

      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.collisions, <Collidable>[blockB, innerBlockB]);
      expect(blockB.collisions, <Collidable>[blockA, innerBlockA]);
      expect(innerBlockA.collisions, <Collidable>[blockB, innerBlockB]);
      expect(innerBlockB.collisions, <Collidable>[blockA, innerBlockA]);
    });
  });
}
