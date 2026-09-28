import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

/// Two squares of side 10, with a gap of 10 between them.
Path _twoSquares() {
  return Path()
    ..addRect(const Rect.fromLTWH(0, 0, 10, 10))
    ..addRect(const Rect.fromLTWH(20, 0, 10, 10));
}

TestBlock _pathBlock(Vector2 position, {bool isSolid = false}) {
  return TestBlock(position, Vector2(30, 10), addTestHitbox: false)
    ..add(PathHitbox(path: _twoSquares(), isSolid: isSolid));
}

void main() {
  group('PathHitbox', () {
    test('has one polygon per closed contour', () {
      final hitbox = PathHitbox(path: _twoSquares());

      expect(hitbox.polygons.length, 2);
    });

    test('takes the collision type', () {
      final hitbox = PathHitbox(
        path: _twoSquares(),
        collisionType: CollisionType.passive,
      );

      expect(hitbox.collisionType, CollisionType.passive);
    });

    test('can not fill its parent', () {
      final hitbox = PathHitbox(path: _twoSquares());

      expect(hitbox.fillParent, throwsUnsupportedError);
    });

    test('contains the points of its polygons and not the gap', () {
      final hitbox = PathHitbox(path: _twoSquares());

      expect(hitbox.containsLocalPoint(Vector2(5, 5)), isTrue);
      expect(hitbox.containsLocalPoint(Vector2(25, 5)), isTrue);
      expect(hitbox.containsLocalPoint(Vector2(15, 5)), isFalse);
    });

    runCollisionTestRegistry({
      'the aabb covers all the polygons': (game) async {
        final block = _pathBlock(Vector2(100, 100));
        final hitbox = block.firstChild<PathHitbox>()!;
        await game.ensureAdd(block);
        game.update(0);

        expect(hitbox.aabb.min, closeToVector(Vector2(100, 100), 0.01));
        expect(hitbox.aabb.max, closeToVector(Vector2(130, 110), 0.01));
      },
      'the aabb follows the hitbox': (game) async {
        final block = _pathBlock(Vector2(100, 100));
        final hitbox = block.firstChild<PathHitbox>()!;
        await game.ensureAdd(block);
        game.update(0);
        block.position = Vector2(200, 200);
        game.update(0);

        expect(hitbox.aabb.min, closeToVector(Vector2(200, 200), 0.01));
        expect(hitbox.aabb.max, closeToVector(Vector2(230, 210), 0.01));
      },
      'contains the global points of its polygons': (game) async {
        final block = _pathBlock(Vector2(100, 100));
        final hitbox = block.firstChild<PathHitbox>()!;
        await game.ensureAdd(block);
        game.update(0);

        expect(hitbox.containsPoint(Vector2(105, 105)), isTrue);
        expect(hitbox.containsPoint(Vector2(125, 105)), isTrue);
        expect(hitbox.containsPoint(Vector2(115, 105)), isFalse);
        expect(hitbox.containsPoint(Vector2(95, 105)), isFalse);
      },
      'does not collide with itself': (game) async {
        final block = _pathBlock(Vector2.zero());
        await game.ensureAdd(block);
        game.update(0);
        game.update(0);

        expect(block.startCounter, 0);
        expect(block.isColliding, isFalse);
      },
      'collides with a circle that touches the second polygon': (game) async {
        final block = _pathBlock(Vector2.zero());
        final circle = TestBlock(
          Vector2(25, 5),
          Vector2.all(10),
          addTestHitbox: false,
        )..add(CircleHitbox());
        await game.ensureAddAll([block, circle]);
        game.update(0);

        expect(block.collidingWith(circle), isTrue);
        expect(circle.collidingWith(block), isTrue);
        expect(block.startCounter, 1);
        expect(circle.startCounter, 1);
      },
      'does not collide with a circle in the gap': (game) async {
        final block = _pathBlock(Vector2.zero());
        final circle = TestBlock(
          Vector2(12.5, 2.5),
          Vector2.all(5),
          addTestHitbox: false,
        )..add(CircleHitbox());
        await game.ensureAddAll([block, circle]);
        game.update(0);

        expect(block.collidingWith(circle), isFalse);
        expect(block.startCounter, 0);
        expect(circle.startCounter, 0);
      },
      'collides with a rectangle that touches the second polygon':
          (game) async {
            final block = _pathBlock(Vector2.zero());
            final rectangle = TestBlock(Vector2(25, 5), Vector2.all(10));
            await game.ensureAddAll([block, rectangle]);
            game.update(0);

            expect(block.collidingWith(rectangle), isTrue);
            expect(rectangle.collidingWith(block), isTrue);
            expect(block.startCounter, 1);
            expect(rectangle.startCounter, 1);
          },
      'collides with another path': (game) async {
        final blockA = _pathBlock(Vector2.zero());
        final blockB = _pathBlock(Vector2(25, 5));
        await game.ensureAddAll([blockA, blockB]);
        game.update(0);

        expect(blockA.collidingWith(blockB), isTrue);
        expect(blockB.collidingWith(blockA), isTrue);
        expect(blockA.startCounter, 1);
        expect(blockB.startCounter, 1);
      },
      'reports one collision when several polygons touch the other hitbox':
          (game) async {
            final block = _pathBlock(Vector2.zero());
            final rectangle = TestBlock(Vector2(5, 5), Vector2(20, 10));
            await game.ensureAddAll([block, rectangle]);
            game.update(0);

            expect(block.startCounter, 1);
            expect(rectangle.startCounter, 1);
            expect(block.activeCollisions.length, 1);
            expect(rectangle.activeCollisions.length, 1);
          },
      'reports the intersection points of all the polygons': (game) async {
        final block = _pathBlock(Vector2.zero());
        final hitbox = block.firstChild<PathHitbox>()!;
        final rectangle = TestBlock(Vector2(5, 5), Vector2(20, 10));
        await game.ensureAddAll([block, rectangle]);
        game.update(0);

        final points = hitbox.intersections(rectangle.hitbox);
        expect(points, containsAll([Vector2(10, 5), Vector2(20, 5)]));
      },
      'a hollow path does not collide with a shape inside of a polygon':
          (game) async {
            final block = _pathBlock(Vector2.zero());
            final rectangle = TestBlock(Vector2(2, 2), Vector2.all(6));
            await game.ensureAddAll([block, rectangle]);
            game.update(0);

            expect(block.collidingWith(rectangle), isFalse);
          },
      'a solid path collides with a shape inside of a polygon': (game) async {
        final block = _pathBlock(Vector2.zero(), isSolid: true);
        final rectangle = TestBlock(Vector2(2, 2), Vector2.all(6));
        await game.ensureAddAll([block, rectangle]);
        game.update(0);

        expect(block.collidingWith(rectangle), isTrue);
      },
      'a ray hits the nearest polygon': (game) async {
        final block = _pathBlock(Vector2.zero());
        final hitbox = block.firstChild<PathHitbox>()!;
        await game.ensureAdd(block);
        game.update(0);

        final fromTheLeft = game.collisionDetection.raycast(
          Ray2(origin: Vector2(-5, 5), direction: Vector2(1, 0)),
        );
        expect(fromTheLeft?.hitbox, hitbox);
        expect(fromTheLeft?.distance, closeTo(5, 0.01));
        expect(fromTheLeft?.isInsideHitbox, isFalse);

        final fromTheRight = game.collisionDetection.raycast(
          Ray2(origin: Vector2(35, 5), direction: Vector2(-1, 0)),
        );
        expect(fromTheRight?.hitbox, hitbox);
        expect(fromTheRight?.distance, closeTo(5, 0.01));

        final fromTheGap = game.collisionDetection.raycast(
          Ray2(origin: Vector2(15, 5), direction: Vector2(1, 0)),
        );
        expect(fromTheGap?.distance, closeTo(5, 0.01));
        expect(fromTheGap?.isInsideHitbox, isFalse);

        final fromInside = game.collisionDetection.raycast(
          Ray2(origin: Vector2(5, 5), direction: Vector2(1, 0)),
        );
        expect(fromInside?.distance, closeTo(5, 0.01));
        expect(fromInside?.isInsideHitbox, isTrue);

        final miss = game.collisionDetection.raycast(
          Ray2(origin: Vector2(-5, 15), direction: Vector2(1, 0)),
        );
        expect(miss, isNull);
      },
    });
  });
}
