import 'package:flame/collision_detection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _HasCollidablesGame extends FlameGame with HasCollisionDetection {}

class _TestHitbox extends HitboxRectangle {
  int startCounter = 0;
  int onCollisionCounter = 0;
  int endCounter = 0;

  _TestHitbox() {
    collisionCallback = (_, __) {
      onCollisionCounter++;
    };
    collisionStartCallback = (_, __) {
      startCounter++;
    };
    collisionEndCallback = (_) {
      endCounter++;
    };
  }

  bool hasCollisionWith(HitboxShape otherShape) {
    return activeCollisions.contains(otherShape);
  }
}

class _TestBlock extends PositionComponent with HasHitboxes {
  final hitbox = _TestHitbox();
  int startCounter = 0;
  int onCollisionCounter = 0;
  int endCounter = 0;

  _TestBlock(Vector2 position, Vector2 size)
      : super(
          position: position,
          size: size,
        ) {
    add(hitbox);
  }

  bool hasCollisionWith(Collidable otherCollidable) {
    return activeCollisions.contains(otherCollidable);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, HasHitboxes other) {
    super.onCollisionStart(intersectionPoints, other);
    startCounter++;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, HasHitboxes other) {
    super.onCollision(intersectionPoints, other);
    onCollisionCounter++;
  }

  @override
  void onCollisionEnd(HasHitboxes other) {
    super.onCollisionEnd(other);
    endCounter++;
  }
}

void main() {
  final withCollidables = FlameTester(() => _HasCollidablesGame());

  group('Collision callbacks', () {
    withCollidables.test('collidable callbacks are called', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.hasCollisionWith(blockB), isTrue);
      expect(blockB.hasCollisionWith(blockA), isTrue);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
      expect(blockA.startCounter, 1);
      expect(blockB.startCounter, 1);
      expect(blockA.onCollisionCounter, 1);
      expect(blockB.onCollisionCounter, 1);
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
      print(blockA.topLeftPosition);
      print(blockB.topLeftPosition);
      expect(blockA.hasCollisionWith(blockB), isFalse);
      expect(blockB.hasCollisionWith(blockA), isFalse);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
      game.update(0);
      expect(blockA.endCounter, 1);
      expect(blockB.endCounter, 1);
    });

    withCollidables.test(
      'collidable callbacks are called when removing a Collidable',
      (game) async {
        final blockA = _TestBlock(
          Vector2.zero(),
          Vector2.all(10),
        );
        final blockB = _TestBlock(
          Vector2.all(1),
          Vector2.all(10),
        );
        await game.ensureAddAll([blockA, blockB]);
        game.update(0);
        expect(blockA.hasCollisionWith(blockB), true);
        expect(blockB.hasCollisionWith(blockA), true);
        expect(blockA.activeCollisions.length, 1);
        expect(blockB.activeCollisions.length, 1);
        game.remove(blockA);
        game.update(0);
        expect(blockA.endCounter, 1);
        expect(blockB.endCounter, 1);
        expect(blockA.hasCollisionWith(blockB), false);
        expect(blockB.hasCollisionWith(blockA), false);
        expect(blockA.activeCollisions.length, 0);
        expect(blockB.activeCollisions.length, 0);
      },
    );

    withCollidables.test('hitbox callbacks are called', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
      );
      final hitboxA = blockA.hitbox;
      final hitboxB = blockB.hitbox;
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(hitboxA.hasCollisionWith(hitboxB), true);
      expect(hitboxB.hasCollisionWith(hitboxA), true);
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
      expect(hitboxA.hasCollisionWith(hitboxB), false);
      expect(hitboxB.hasCollisionWith(hitboxA), false);
      expect(hitboxA.activeCollisions.length, 0);
      expect(hitboxB.activeCollisions.length, 0);
      expect(hitboxA.endCounter, 1);
      expect(hitboxB.endCounter, 1);
    });
  });

  withCollidables.test(
    'hitbox callbacks are called when Collidable is removed',
    (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
      );
      final hitboxA = blockA.hitbox;
      final hitboxB = blockB.hitbox;
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(hitboxA.hasCollisionWith(hitboxB), true);
      expect(hitboxB.hasCollisionWith(hitboxA), true);
      expect(hitboxA.activeCollisions.length, 1);
      expect(hitboxB.activeCollisions.length, 1);
      game.remove(blockA);
      game.update(0);
      expect(hitboxA.hasCollisionWith(hitboxB), false);
      expect(hitboxB.hasCollisionWith(hitboxA), false);
      expect(hitboxA.activeCollisions.length, 0);
      expect(hitboxB.activeCollisions.length, 0);
      expect(hitboxA.endCounter, 1);
      expect(hitboxB.endCounter, 1);
    },
  );
}
