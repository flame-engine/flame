import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

/// A star, which is concave, so that its box is much bigger than its area.
Path _star() {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final radius = i.isEven ? 40.0 : 15.0;
    final angle = i * pi / 5;
    final x = 40 + radius * cos(angle);
    final y = 40 + radius * sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  return path..close();
}

/// Hitboxes of all kinds, placed randomly in an area of 800x600.
List<ShapeHitbox> _scene(Random random, int count) {
  Vector2 position() =>
      Vector2(random.nextDouble() * 800, random.nextDouble() * 600);
  return [
    for (var i = 0; i < count; i++)
      switch (i % 4) {
        0 => RectangleHitbox(
          position: position(),
          size: Vector2(
            20 + random.nextDouble() * 60,
            20 + random.nextDouble() * 60,
          ),
          angle: random.nextDouble() * 2 * pi,
          anchor: Anchor.center,
        ),
        1 => CircleHitbox(
          position: position(),
          radius: 10 + random.nextDouble() * 30,
          anchor: Anchor.center,
        ),
        2 => PolygonHitbox(
          [
            Vector2(0, -1),
            Vector2(0.9, 0.5),
            Vector2(-0.9, 0.5),
          ].map((v) => v * (15 + random.nextDouble() * 30)).toList(),
          position: position(),
          angle: random.nextDouble() * 2 * pi,
          anchor: Anchor.center,
        ),
        _ => PathHitbox(
          path: _star(),
          position: position(),
          angle: random.nextDouble() * 2 * pi,
          anchor: Anchor.center,
        ),
      },
  ];
}

List<Ray2> _rays(Random random, int count) {
  return [
    for (var i = 0; i < count; i++)
      Ray2(
        origin: Vector2(random.nextDouble() * 800, random.nextDouble() * 600),
        direction: Vector2(random.nextDouble() - 0.5, random.nextDouble() - 0.5)
          ..normalize(),
      ),
  ];
}

/// Adds the hitboxes to the game, each in a component, as they need one.
void _addAll(HasCollidablesGame game, Iterable<ShapeHitbox> hitboxes) {
  game.addAll([
    for (final hitbox in hitboxes) PositionComponent(children: [hitbox]),
  ]);
}

/// The result of casting the [ray] with the old and the new code path.
(RaycastResult<ShapeHitbox>?, RaycastResult<ShapeHitbox>?) _both(
  CollisionDetection<ShapeHitbox, Broadphase<ShapeHitbox>> detection,
  Ray2 ray, {
  double? maxDistance,
  bool Function(ShapeHitbox candidate)? hitboxFilter,
  List<ShapeHitbox>? ignoreHitboxes,
}) {
  RaycastResult<ShapeHitbox>? cast() => detection.raycast(
    ray,
    maxDistance: maxDistance,
    hitboxFilter: hitboxFilter,
    ignoreHitboxes: ignoreHitboxes,
  );
  StandardCollisionDetection.nearestFirstRaycast = false;
  final expected = cast();
  StandardCollisionDetection.nearestFirstRaycast = true;
  final actual = cast();
  return (expected, actual);
}

void _expectSame(
  RaycastResult<ShapeHitbox>? actual,
  RaycastResult<ShapeHitbox>? expected,
) {
  if (expected == null) {
    expect(actual, isNull);
    return;
  }
  expect(actual, isNotNull);
  expect(actual!.hitbox, same(expected.hitbox));
  expect(actual.distance, closeTo(expected.distance!, 1e-9));
  expect(actual.isInsideHitbox, expected.isInsideHitbox);
  expect(
    actual.intersectionPoint!.x,
    closeTo(expected.intersectionPoint!.x, 1e-9),
  );
  expect(
    actual.intersectionPoint!.y,
    closeTo(expected.intersectionPoint!.y, 1e-9),
  );
  expect(actual.normal!.x, closeTo(expected.normal!.x, 1e-9));
  expect(actual.normal!.y, closeTo(expected.normal!.y, 1e-9));
}

void main() {
  tearDown(() => StandardCollisionDetection.nearestFirstRaycast = false);

  group('StandardCollisionDetection.nearestFirstRaycast', () {
    test('is off by default', () {
      expect(StandardCollisionDetection.nearestFirstRaycast, isFalse);
    });

    testCollisionDetectionGame('finds nothing in an empty world', (game) async {
      await game.ready();
      StandardCollisionDetection.nearestFirstRaycast = true;
      final ray = Ray2(origin: Vector2.zero(), direction: Vector2(1, 0));
      expect(game.collisionDetection.raycast(ray), isNull);
    });

    testCollisionDetectionGame('finds the same hits as the old code', (
      game,
    ) async {
      final random = Random(1);
      _addAll(game, _scene(random, 60));
      await game.ready();
      var hits = 0;
      for (final ray in _rays(random, 400)) {
        final (expected, actual) = _both(game.collisionDetection, ray);
        _expectSame(actual, expected);
        hits += expected == null ? 0 : 1;
      }
      // The scene is dense enough for the comparison to mean something.
      expect(hits, greaterThan(200));
    });

    testCollisionDetectionGame('finds the same hits with maxDistance', (
      game,
    ) async {
      final random = Random(2);
      _addAll(game, _scene(random, 60));
      await game.ready();
      var hits = 0;
      var misses = 0;
      for (final ray in _rays(random, 400)) {
        final maxDistance = 20 + random.nextDouble() * 200;
        final (expected, actual) = _both(
          game.collisionDetection,
          ray,
          maxDistance: maxDistance,
        );
        _expectSame(actual, expected);
        if (expected == null) {
          misses++;
        } else {
          expect(expected.distance, lessThanOrEqualTo(maxDistance));
          hits++;
        }
      }
      expect(hits, greaterThan(20));
      expect(misses, greaterThan(20));
    });

    testCollisionDetectionGame('finds the same hits with many candidates', (
      game,
    ) async {
      // Big hitboxes, so that a ray reaches hundreds of them, which makes the
      // heap that orders them grow several times.
      final random = Random(6);
      ShapeHitbox big(int index) {
        if (index.isEven) {
          return RectangleHitbox(
            position: Vector2(
              random.nextDouble() * 800 - 200,
              random.nextDouble() * 600 - 200,
            ),
            size: Vector2(
              150 + random.nextDouble() * 350,
              150 + random.nextDouble() * 350,
            ),
          );
        }
        return PathHitbox(
          path: _star(),
          position: Vector2(
            random.nextDouble() * 800,
            random.nextDouble() * 600,
          ),
          angle: random.nextDouble() * 2 * pi,
        );
      }

      final hitboxes = [for (var i = 0; i < 300; i++) big(i)];
      _addAll(game, hitboxes);
      await game.ready();
      var hits = 0;
      for (final ray in _rays(random, 300)) {
        final maxDistance = random.nextBool()
            ? null
            : 50 + random.nextDouble() * 400;
        final (expected, actual) = _both(
          game.collisionDetection,
          ray,
          maxDistance: maxDistance,
        );
        _expectSame(actual, expected);
        hits += expected == null ? 0 : 1;
      }
      expect(hits, greaterThan(100));
    });

    testCollisionDetectionGame('does not keep hitboxes after a ray', (
      game,
    ) async {
      final hitbox = RectangleHitbox(
        position: Vector2(100, 0),
        size: Vector2.all(100),
      );
      _addAll(game, [hitbox]);
      await game.ready();
      StandardCollisionDetection.nearestFirstRaycast = true;
      final ray = Ray2(origin: Vector2(0, 50), direction: Vector2(1, 0));
      expect(game.collisionDetection.raycast(ray), isNotNull);
      // Even if a callback throws, a later ray works.
      expect(
        () => game.collisionDetection.raycast(
          ray,
          hitboxFilter: (_) => throw StateError('callback'),
        ),
        throwsStateError,
      );
      expect(game.collisionDetection.raycast(ray)!.hitbox, same(hitbox));
    });

    testCollisionDetectionGame('casts rays from inside of a hitbox filter', (
      game,
    ) async {
      final near = RectangleHitbox(
        position: Vector2(100, 0),
        size: Vector2.all(100),
      );
      final far = RectangleHitbox(
        position: Vector2(300, 0),
        size: Vector2.all(100),
      );
      _addAll(game, [near, far]);
      await game.ready();
      StandardCollisionDetection.nearestFirstRaycast = true;
      final ray = Ray2(origin: Vector2(0, 50), direction: Vector2(1, 0));
      final nested = <ShapeHitbox?>[];
      final result = game.collisionDetection.raycast(
        ray,
        hitboxFilter: (hitbox) {
          // A ray cast while another is, which must not disturb the outer one.
          nested.add(game.collisionDetection.raycast(ray)?.hitbox);
          return true;
        },
      );
      expect(result!.hitbox, same(near));
      expect(result.distance, closeTo(100, 1e-9));
      expect(nested, hasLength(2));
      expect(nested, everyElement(same(near)));
    });

    testCollisionDetectionGame('finds the same hits for axis aligned rays', (
      game,
    ) async {
      final random = Random(3);
      _addAll(game, _scene(random, 60));
      await game.ready();
      final directions = [
        Vector2(1, 0),
        Vector2(-1, 0),
        Vector2(0, 1),
        Vector2(0, -1),
      ];
      for (final direction in directions) {
        for (var i = 0; i < 100; i++) {
          final ray = Ray2(
            origin: Vector2(
              random.nextDouble() * 800,
              random.nextDouble() * 600,
            ),
            direction: direction,
          );
          final (expected, actual) = _both(game.collisionDetection, ray);
          _expectSame(actual, expected);
        }
      }
    });

    testCollisionDetectionGame('respects hitboxFilter and ignoreHitboxes', (
      game,
    ) async {
      final random = Random(4);
      final hitboxes = _scene(random, 60);
      _addAll(game, hitboxes);
      await game.ready();
      final ignored = hitboxes.take(20).toList();
      for (final ray in _rays(random, 200)) {
        final (expectedFiltered, actualFiltered) = _both(
          game.collisionDetection,
          ray,
          hitboxFilter: (hitbox) => hitbox is! CircleHitbox,
        );
        _expectSame(actualFiltered, expectedFiltered);
        expect(actualFiltered?.hitbox, isNot(isA<CircleHitbox>()));
        final (expectedIgnoring, actualIgnoring) = _both(
          game.collisionDetection,
          ray,
          ignoreHitboxes: ignored,
        );
        _expectSame(actualIgnoring, expectedIgnoring);
        expect(ignored, isNot(contains(actualIgnoring?.hitbox)));
      }
    });

    testCollisionDetectionGame('finds the nearer hitbox behind a nearer box', (
      game,
    ) async {
      // The box of the triangle, from (100, 0) to (200, 100), is nearer to the
      // rays than the square, but its empty corner at (200, 100) is in it.
      final triangle = PolygonHitbox([
        Vector2(0, 0),
        Vector2(100, 0),
        Vector2(0, 100),
      ], position: Vector2(100, 0));
      final square = RectangleHitbox(
        position: Vector2(300, 80),
        size: Vector2.all(20),
      );
      _addAll(game, [triangle, square]);
      await game.ready();
      StandardCollisionDetection.nearestFirstRaycast = true;
      // Starts inside of the box, outside of the triangle, going away from it.
      final empty = Ray2(origin: Vector2(190, 90), direction: Vector2(1, 0));
      final emptyResult = game.collisionDetection.raycast(empty);
      expect(emptyResult!.hitbox, same(square));
      expect(emptyResult.distance, closeTo(110, 1e-9));
      // Hits the triangle first.
      final through = Ray2(origin: Vector2(0, 20), direction: Vector2(1, 0));
      final throughResult = game.collisionDetection.raycast(through);
      expect(throughResult!.hitbox, same(triangle));
      expect(throughResult.distance, closeTo(100, 1e-9));
    });

    testCollisionDetectionGame('starts inside of a hitbox', (game) async {
      final square = RectangleHitbox(
        position: Vector2.zero(),
        size: Vector2.all(100),
      );
      _addAll(game, [square]);
      await game.ready();
      StandardCollisionDetection.nearestFirstRaycast = true;
      final ray = Ray2(origin: Vector2.all(50), direction: Vector2(1, 0));
      final result = game.collisionDetection.raycast(ray);
      expect(result!.isInsideHitbox, isTrue);
      expect(result.distance, closeTo(50, 1e-9));
    });

    testCollisionDetectionGame('populates and returns the given result', (
      game,
    ) async {
      final square = RectangleHitbox(
        position: Vector2(100, 0),
        size: Vector2.all(100),
      );
      _addAll(game, [square]);
      await game.ready();
      StandardCollisionDetection.nearestFirstRaycast = true;
      final out = RaycastResult<ShapeHitbox>();
      final hit = Ray2(origin: Vector2(0, 50), direction: Vector2(1, 0));
      final result = game.collisionDetection.raycast(hit, out: out);
      expect(result, same(out));
      expect(out.hitbox, same(square));
      expect(out.distance, closeTo(100, 1e-9));
      final miss = Ray2(origin: Vector2(0, 500), direction: Vector2(1, 0));
      expect(game.collisionDetection.raycast(miss, out: out), isNull);
      expect(out.isActive, isFalse);
    });

    testCollisionDetectionGame('works for raycastAll and raytrace', (
      game,
    ) async {
      final random = Random(5);
      _addAll(game, _scene(random, 40));
      await game.ready();
      final origin = Vector2(400, 300);
      List<double?> distances({required bool nearestFirst}) {
        StandardCollisionDetection.nearestFirstRaycast = nearestFirst;
        return [
          ...game.collisionDetection
              .raycastAll(origin, numberOfRays: 90)
              .map((r) => r.distance),
          ...game.collisionDetection
              .raytrace(
                Ray2(origin: origin, direction: Vector2(1, 0.3)..normalize()),
              )
              .map((r) => r.distance),
        ];
      }

      final expected = distances(nearestFirst: false);
      final actual = distances(nearestFirst: true);
      expect(actual.length, expected.length);
      for (var i = 0; i < actual.length; i++) {
        expect(actual[i], closeTo(expected[i]!, 1e-9));
      }
    });
  });
}
