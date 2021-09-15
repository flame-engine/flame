import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

class TestGame extends FlameGame with HasCollidables {
  TestGame() {
    onGameResize(Vector2.all(200));
  }
}

class TestBlock extends PositionComponent with Hitbox, Collidable {
  final List<Collidable> collisions = List.empty(growable: true);

  TestBlock(Vector2 position, Vector2 size, CollidableType type)
      : super(
          position: position,
          size: size,
        ) {
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
  Future<TestGame> gameWithCollidables(List<Collidable> collidables) async {
    final game = TestGame();
    await game.onLoad();
    await game.addAll(collidables);
    game.update(0);
    expect(game.children.isNotEmpty, collidables.isNotEmpty);
    return game;
  }

  group(
    'Varying CollisionType tests',
    () {
      test('Actives do collide', () async {
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
        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collidedWith(blockB), true);
        expect(blockB.collidedWith(blockA), true);
        expect(blockA.collisions.length, 1);
        expect(blockB.collisions.length, 1);
      });

      test('Sensors do not collide', () async {
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
        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.isEmpty, true);
        expect(blockB.collisions.isEmpty, true);
      });

      test('Inactives do not collide', () async {
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
        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.isEmpty, true);
        expect(blockB.collisions.isEmpty, true);
      });

      test('Active collides with static', () async {
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
        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collidedWith(blockB), true);
        expect(blockB.collidedWith(blockA), true);
        expect(blockA.collisions.length, 1);
        expect(blockB.collisions.length, 1);
      });

      test('Sensor collides with active', () async {
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
        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collidedWith(blockB), true);
        expect(blockB.collidedWith(blockA), true);
        expect(blockA.collisions.length, 1);
        expect(blockB.collisions.length, 1);
      });

      test('Sensor does not collide with inactive', () async {
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
        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.length, 0);
        expect(blockB.collisions.length, 0);
      });

      test('Inactive does not collide with static', () async {
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
        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.length, 0);
        expect(blockB.collisions.length, 0);
      });

      test('Active does not collide with inactive', () async {
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
        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.length, 0);
        expect(blockB.collisions.length, 0);
      });

      test('Inactive does not collide with active', () async {
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
        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.length, 0);
        expect(blockB.collisions.length, 0);
      });

      test('Correct collisions with many involved collidables', () async {
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
        await gameWithCollidables((actives + statics + inactives)..shuffle());
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
      });

      test('Detects collision after scale', () async {
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
        final game = await gameWithCollidables([blockA, blockB]);
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

      test('TestPoint detects point after scale', () async {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.active,
        );
        final game = await gameWithCollidables([blockA]);
        expect(blockA.containsPoint(Vector2.all(11)), false);
        blockA.scale = Vector2.all(2.0);
        game.update(0);
        expect(blockA.containsPoint(Vector2.all(11)), true);
      });

      test('Detects collision on child components', () async {
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

        await gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions, <Collidable>[blockB, innerBlockB]);
        expect(blockB.collisions, <Collidable>[blockA, innerBlockA]);
        expect(innerBlockA.collisions, <Collidable>[blockB, innerBlockB]);
        expect(innerBlockB.collisions, <Collidable>[blockA, innerBlockA]);
      });
    },
  );
}
