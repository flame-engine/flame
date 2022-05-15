import 'package:flame/components.dart';
import 'package:flame/src/collisions/collision_passthrough.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

class Passthrough extends TestBlock with CollisionPassthrough {
  Passthrough() : super(Vector2.zero(), Vector2.all(10));
}

void main() {
  group('CollisionPassthrough', () {
    testCollidableGame('Passing collisions to parent', (game) async {
      final passthrough = Passthrough();
      final hitboxParent =
          TestBlock(Vector2.zero(), Vector2.all(10), addTestHitbox: false)
            ..add(passthrough);
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
    });
  });
}
