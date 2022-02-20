import 'dart:math';

import 'package:flame/collision_detection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

class _TestBlock extends PositionComponent with CollisionCallbacks {
  final Vector2 velocity;
  static int collisionCounter = 0;

  _TestBlock(Vector2 position, Vector2 size, this.velocity)
      : super(
          position: position,
          size: size,
        ) {
    add(HitboxCircle());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    collisionCounter++;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (position.length2 > 100000) {
      velocity.negate();
    }
    position.add(velocity * dt);
  }
}

void main() {
  group('Benchmark collision detection', () {
    withCollidables.test('collidable callbacks are called', (game) async {
      final rng = Random(0);
      final blocks = List.generate(
        100,
        (_) => _TestBlock(
          Vector2.random(rng) * game.size.x,
          Vector2.random(rng) * 100,
          Vector2(
            rng.nextInt(100) * (rng.nextBool() ? 1 : -1),
            rng.nextInt(100) * (rng.nextBool() ? 1 : -1),
          ),
        ),
      );
      await game.ensureAddAll(blocks);
      final startTime = DateTime.now();
      const ticks = 1000;
      for (var i = 0; i < ticks; i++) {
        game.update(1 / 60);
      }
      final totalTime = DateTime.now().millisecondsSinceEpoch -
          startTime.millisecondsSinceEpoch;
      print(
        '$totalTime ms\n'
        '${1000 / (totalTime / ticks)} runs per second\n'
        '${_TestBlock.collisionCounter}',
      );
    });
  });
}
