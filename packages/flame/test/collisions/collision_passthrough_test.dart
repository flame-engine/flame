import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

class _Passthrough extends TestBlock with CollisionPassthrough {
  _Passthrough() : super(Vector2.zero(), Vector2.all(10));
}

void main() {
  group('CollisionPassthrough', () {
    runCollisionTestRegistry({
      'Passing collisions to parent': (game) async {
        final passthrough = _Passthrough();
        final hitboxParent = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          addTestHitbox: false,
        )..add(passthrough);
        final collisionBlock = TestBlock(Vector2.all(1), Vector2.all(10));
        game.add(collisionBlock);
        game.add(hitboxParent);
        game.update(0);
        expect(hitboxParent.isColliding, isTrue);
        expect(passthrough.isColliding, isTrue);
        expect(passthrough.startCounter, 1);
        expect(passthrough.onCollisionCounter, 1);
        expect(passthrough.endCounter, 0);
        expect(hitboxParent.startCounter, 1);
        expect(hitboxParent.onCollisionCounter, 1);
        expect(hitboxParent.endCounter, 0);
        collisionBlock.position = Vector2.all(12);
        game.update(0);
        expect(hitboxParent.isColliding, isFalse);
        expect(passthrough.isColliding, isFalse);
        expect(passthrough.startCounter, 1);
        expect(passthrough.endCounter, 1);
        expect(passthrough.onCollisionCounter, 1);
        expect(hitboxParent.startCounter, 1);
        expect(hitboxParent.endCounter, 1);
        expect(hitboxParent.onCollisionCounter, 1);
      },
    });

    testWithFlameGame('Null passthrough', (game) async {
      final hitbox = CompositeHitbox(children: [RectangleHitbox()]);
      final component = PositionComponent(children: [hitbox]);
      final testBlock = TestBlock(Vector2.zero(), Vector2.all(10));

      await game.addAll([component, testBlock]);
      await game.ready();

      expect(hitbox.passthroughParent, isNull);

      hitbox.removeFromParent();
      testBlock.add(hitbox);
      await game.ready();

      expect(hitbox.passthroughParent, testBlock);
    });
  });
}
