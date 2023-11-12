import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

void main() {
  group('ScreenHitbox', () {
    runCollisionTestRegistry({
      'collides': (hasCollisionDetection) async {
        final game = hasCollisionDetection as FlameGame;
        final visibleRect = game.camera.visibleWorldRect;
        final testBlock = TestBlock(
          visibleRect.topLeft.toVector2(),
          Vector2.all(10),
        )..anchor = Anchor.center;
        final screenHitbox = ScreenHitbox();
        await game.world.addAll([screenHitbox, testBlock]);
        await game.ready();
        game.update(0);

        expect(testBlock.startCounter, 1);
        expect(testBlock.onCollisionCounter, 1);
        expect(testBlock.endCounter, 0);
        expect(testBlock.completedCounter, 1);

        testBlock.position = Vector2.zero();
        game.update(0);

        expect(testBlock.startCounter, 1);
        expect(testBlock.onCollisionCounter, 1);
        expect(testBlock.endCounter, 1);
        expect(testBlock.completedCounter, 2);
      },
    });

    runCollisionTestRegistry({
      'collides when zoom is not 1.0': (hasCollisionDetection) async {
        final game = hasCollisionDetection as FlameGame;
        game.camera.viewfinder.zoom = 2.5;
        final visibleRect = game.camera.visibleWorldRect;
        final testBlock = TestBlock(
          visibleRect.topLeft.toVector2(),
          Vector2.all(10),
        )..anchor = Anchor.center;
        final screenHitbox = ScreenHitbox();
        await game.world.addAll([screenHitbox, testBlock]);
        await game.ready();
        game.update(0);

        expect(testBlock.startCounter, 1);
        expect(testBlock.onCollisionCounter, 1);
        expect(testBlock.endCounter, 0);
        expect(testBlock.completedCounter, 1);

        testBlock.position = Vector2.zero();
        game.update(0);

        expect(testBlock.startCounter, 1);
        expect(testBlock.onCollisionCounter, 1);
        expect(testBlock.endCounter, 1);
        expect(testBlock.completedCounter, 2);
      },
    });

    runCollisionTestRegistry({
      'collides when game size changes': (hasCollisionDetection) async {
        final game = hasCollisionDetection as FlameGame;
        final visibleRect = game.camera.visibleWorldRect;
        final testBlock = TestBlock(
          visibleRect.topLeft.toVector2() / 2,
          Vector2.all(10),
        )..anchor = Anchor.center;
        final screenHitbox = ScreenHitbox();
        await game.world.addAll([screenHitbox, testBlock]);
        await game.ready();
        game.update(0);

        expect(testBlock.startCounter, 0);
        expect(testBlock.onCollisionCounter, 0);
        expect(testBlock.endCounter, 0);
        expect(testBlock.completedCounter, 1);

        testBlock.position = visibleRect.topLeft.toVector2() / 2;
        game.onGameResize(game.size / 2);
        game.update(0);

        expect(testBlock.startCounter, 1);
        expect(testBlock.onCollisionCounter, 1);
        expect(testBlock.endCounter, 0);
        expect(testBlock.completedCounter, 2);
      },
    });

    runCollisionTestRegistry({
      'collides when angle is not 0.0': (hasCollisionDetection) async {
        final game = hasCollisionDetection as FlameGame;
        final visibleRectBeforeRotation = game.camera.visibleWorldRect;
        game.camera.viewfinder.angle = tau / 8;
        final visibleRect = game.camera.visibleWorldRect;
        final testBlock = TestBlock(
          visibleRect.topLeft.toVector2(),
          Vector2.all(10),
        )..anchor = Anchor.center;
        final screenHitbox = ScreenHitbox();
        await game.world.addAll([screenHitbox, testBlock]);
        await game.ready();
        game.update(0);

        expect(testBlock.startCounter, 0);
        expect(testBlock.onCollisionCounter, 0);
        expect(testBlock.endCounter, 0);
        expect(testBlock.completedCounter, 1);

        testBlock.position = visibleRectBeforeRotation.topLeft.toVector2();
        game.update(0);

        expect(testBlock.startCounter, 1);
        expect(testBlock.onCollisionCounter, 1);
        expect(testBlock.endCounter, 0);
        expect(testBlock.completedCounter, 2);
      },
    });
  });
}
