import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('SpawnComponent', () {
    testWithFlameGame('Spawns components within rectangle', (game) async {
      final random = Random(0);
      final shape = Rectangle.fromCenter(
        center: Vector2(100, 200),
        size: Vector2.all(200),
      );
      final spawn = SpawnComponent(
        factory: (_) => PositionComponent(),
        period: 1,
        area: shape,
        random: random,
      );
      final world = game.world;
      await world.ensureAdd(spawn);
      game.update(0.5);
      expect(world.children.length, 1);
      game.update(0.5);
      game.update(0.0);
      expect(world.children.length, 2);
      game.update(1.0);
      game.update(0.0);
      expect(world.children.length, 3);

      for (var i = 0; i < 1000; i++) {
        game.update(random.nextDouble());
      }
      expect(
        world.children
            .query<PositionComponent>()
            .every((c) => shape.containsPoint(c.position)),
        isTrue,
      );
    });

    testWithFlameGame(
      'Spawns multiple components within rectangle',
      (game) async {
        final random = Random(0);
        final shape = Rectangle.fromCenter(
          center: Vector2(100, 200),
          size: Vector2.all(200),
        );
        final spawn = SpawnComponent(
          multiFactory: (_) =>
              [PositionComponent(), PositionComponent(), PositionComponent()],
          period: 1,
          area: shape,
          random: random,
        );
        final world = game.world;
        await world.ensureAdd(spawn);
        game.update(0.5);
        expect(world.children.length, 1); //1 being the spawnComponent
        game.update(0.5);
        game.update(0.0);
        expect(world.children.length, 4); //1+3 spawned components
        game.update(1.0);
        game.update(0.0);
        expect(world.children.length, 7); //1+2*3 spawned components

        for (var i = 0; i < 1000; i++) {
          game.update(random.nextDouble());
        }
        expect(
          world.children
              .query<PositionComponent>()
              .every((c) => shape.containsPoint(c.position)),
          isTrue,
        );
      },
    );

    testWithFlameGame('Spawns components within circle', (game) async {
      final random = Random(0);
      final shape = Circle(Vector2(100, 200), 100);
      expect(shape.containsPoint(Vector2.all(200)), isTrue);
      final spawn = SpawnComponent(
        factory: (_) => PositionComponent(),
        period: 1,
        area: shape,
        random: random,
      );
      final world = game.world;
      await world.ensureAdd(spawn);
      game.update(0.5);
      expect(world.children.length, 1);
      game.update(0.5);
      game.update(0.0);
      expect(world.children.length, 2);
      game.update(1.0);
      game.update(0.0);
      expect(world.children.length, 3);

      for (var i = 0; i < 1000; i++) {
        game.update(random.nextDouble());
      }
      expect(
        world.children
            .query<PositionComponent>()
            .every((c) => shape.containsPoint(c.position)),
        isTrue,
      );
    });

    testWithFlameGame('Spawns components within polygon', (game) async {
      final random = Random(0);
      final shape = Polygon(
        [
          Vector2(100, 100),
          Vector2(200, 100),
          Vector2(150, 200),
        ],
      );
      expect(shape.containsPoint(Vector2.all(150)), isTrue);
      final spawn = SpawnComponent(
        factory: (_) => PositionComponent(),
        period: 1,
        area: shape,
        random: random,
      );
      final world = game.world;
      await world.ensureAdd(spawn);
      game.update(0.5);
      expect(world.children.length, 1);
      game.update(0.5);
      game.update(0.0);
      expect(world.children.length, 2);
      game.update(1.0);
      game.update(0.0);
      expect(world.children.length, 3);

      for (var i = 0; i < 1000; i++) {
        game.update(random.nextDouble());
      }
      expect(
        world.children
            .query<PositionComponent>()
            .every((c) => shape.containsPoint(c.position)),
        isTrue,
      );
    });

    testWithFlameGame('Can self position', (game) async {
      final random = Random(0);
      final spawn = SpawnComponent(
        factory: (_) => PositionComponent(position: Vector2.all(1000)),
        period: 1,
        selfPositioning: true,
        random: random,
      );
      final world = game.world;
      await world.ensureAdd(spawn);
      game.update(0.5);
      expect(world.children.length, 1);
      game.update(0.5);
      game.update(0.0);
      expect(world.children.length, 2);
      game.update(1.0);
      game.update(0.0);
      expect(world.children.length, 3);

      for (var i = 0; i < 1000; i++) {
        game.update(random.nextDouble());
      }
      expect(
        world.children
            .query<PositionComponent>()
            .every((c) => c.position == Vector2.all(1000)),
        isTrue,
      );
    });

    testWithFlameGame('Can self position multiple components', (game) async {
      final random = Random(0);
      final spawn = SpawnComponent(
        multiFactory: (_) => [
          PositionComponent(position: Vector2.all(1000)),
          PositionComponent(position: Vector2.all(1000)),
          PositionComponent(position: Vector2.all(1000)),
        ],
        period: 1,
        selfPositioning: true,
        random: random,
      );
      final world = game.world;
      await world.ensureAdd(spawn);
      game.update(0.5);
      expect(world.children.length, 1); //1 spawned component
      game.update(0.5);
      game.update(0.0);
      expect(world.children.length, 4); //1+3 spawned components
      game.update(1.0);
      game.update(0.0);
      expect(world.children.length, 7); //1+2*3 spawned components

      for (var i = 0; i < 1000; i++) {
        game.update(random.nextDouble());
      }
      expect(
        world.children
            .query<PositionComponent>()
            .every((c) => c.position == Vector2.all(1000)),
        isTrue,
      );
    });

    testWithFlameGame('Does not spawns when auto start is false', (game) async {
      final random = Random(0);
      final shape = Rectangle.fromCenter(
        center: Vector2(100, 200),
        size: Vector2.all(200),
      );
      final spawn = SpawnComponent(
        factory: (_) => PositionComponent(),
        period: 1,
        area: shape,
        random: random,
        autoStart: false,
      );
      final world = game.world;
      await world.ensureAdd(spawn);
      game.update(1.5);
      await game.ready();
      expect(world.children.length, 1);

      spawn.timer.start();

      game.update(1);
      await game.ready();
      expect(world.children.length, 2);
    });

    testWithFlameGame(
      'Does not spawns right away when spawnWhenLoaded is false (default)',
      (game) async {
        final random = Random(0);
        final shape = Rectangle.fromCenter(
          center: Vector2(100, 200),
          size: Vector2.all(200),
        );
        final spawn = SpawnComponent(
          factory: (_) => PositionComponent(),
          period: 1,
          area: shape,
          random: random,
        );
        final world = game.world;
        await world.ensureAdd(spawn);
        expect(world.children.whereType<PositionComponent>(), isEmpty);
        game.update(1.5);
        await game.ready();
        expect(
          world.children.whereType<PositionComponent>(),
          hasLength(1),
        );
      },
    );

    testWithFlameGame(
      'Spawns right away when spawnWhenLoaded is true',
      (game) async {
        final random = Random(0);
        final shape = Rectangle.fromCenter(
          center: Vector2(100, 200),
          size: Vector2.all(200),
        );
        final spawn = SpawnComponent(
          factory: (_) => PositionComponent(),
          period: 1,
          area: shape,
          random: random,
          spawnWhenLoaded: true,
        );
        final world = game.world;
        await world.ensureAdd(spawn);
        expect(world.children.whereType<PositionComponent>(), hasLength(1));
        game.update(1.5);
        await game.ready();
        expect(
          world.children.whereType<PositionComponent>(),
          hasLength(2),
        );
      },
    );

    testWithFlameGame('Spawns components within irregular period',
        (game) async {
      final random = Random(0);
      // The first two periods will be ~4.3 and ~3.85
      final spawn = SpawnComponent.periodRange(
        factory: (_) => PositionComponent(),
        minPeriod: 1.0,
        maxPeriod: 5.0,
        random: random,
      );
      final world = game.world;
      await world.ensureAdd(spawn);
      expect(world.children.length, 1);
      game.update(0.3);
      game.update(0);
      expect(world.children.length, 1);
      game.update(4.31);
      game.update(0);
      expect(world.children.length, 2);
      game.update(3.86);
      game.update(0);
      expect(world.children.length, 3);
    });

    testWithFlameGame(
      'Stops spawning after reaching spawnCount',
      (game) async {
        final random = Random(0);
        final spawn = SpawnComponent(
          factory: (_) => _CountComponent(),
          period: 1,
          spawnCount: 3,
          random: random,
        );
        final world = game.world;
        await world.ensureAdd(spawn);

        // Simulate updates to reach the spawnCount limit
        game.update(1.0);
        game.update(0.0);
        expect(
          world.children.whereType<_CountComponent>().toList(),
          hasLength(1),
        );
        game.update(1.0);
        game.update(0.0);
        expect(
          world.children.whereType<_CountComponent>().toList(),
          hasLength(2),
        );
        game.update(1.0);
        game.update(0.0);
        expect(
          world.children.whereType<_CountComponent>().toList(),
          hasLength(3),
        );

        // Ensure no more components are spawned after reaching the limit
        game.update(1.0);
        game.update(0.0);
        expect(
          world.children.whereType<_CountComponent>().toList(),
          hasLength(3),
        );
        expect(spawn.isMounted, isFalse);
      },
    );

    testWithFlameGame(
      'Stops spawning multiple components after reaching spawnCount',
      (game) async {
        final random = Random(0);
        final spawn = SpawnComponent(
          multiFactory: (_) => [
            _CountComponent(),
            _CountComponent(),
            _CountComponent(),
          ],
          period: 1,
          spawnCount: 6,
          random: random,
        );
        final world = game.world;
        await world.ensureAdd(spawn);

        // Simulate updates to reach the spawnCount limit
        game.update(1.0);
        game.update(0.0);
        expect(
          world.children.whereType<_CountComponent>().toList(),
          hasLength(3),
        );
        game.update(1.0);
        game.update(0.0);
        expect(
          world.children.whereType<_CountComponent>().toList(),
          hasLength(6),
        );

        // Ensure no more components are spawned after reaching the limit
        game.update(1.0);
        game.update(0.0);
        expect(
          world.children.whereType<_CountComponent>().toList(),
          hasLength(6),
        );
        expect(spawn.isMounted, isFalse);
      },
    );

    group('With target', () {
      testWithFlameGame(
        'Spawns within target bounds',
        (game) async {
          final target = PositionComponent(
            size: Vector2(200, 200),
            position: Vector2(50, 50),
          );
          final spawn = SpawnComponent(
            factory: (_) => PositionComponent(),
            period: 1,
            target: target,
          );
          await game.ensureAdd(target);
          await game.ensureAdd(spawn);

          game.update(1.0);
          game.update(0.0);
          expect(target.children.whereType<PositionComponent>(), hasLength(1));
          expect(
            target.children.query<PositionComponent>().every(
                  (c) => target.toAbsoluteRect().containsPoint(c.position),
                ),
            isTrue,
          );

          game.update(1.0);
          game.update(0.0);
          expect(target.children.whereType<PositionComponent>(), hasLength(2));
          expect(
            target.children.query<PositionComponent>().every(
                  (c) => target.toAbsoluteRect().containsPoint(c.position),
                ),
            isTrue,
          );
        },
      );

      testWithFlameGame(
        'Spawns multiple components within target bounds',
        (game) async {
          final target = PositionComponent(
            size: Vector2(200, 200),
            position: Vector2(50, 50),
          );
          final spawn = SpawnComponent(
            multiFactory: (_) => [
              PositionComponent(),
              PositionComponent(),
              PositionComponent(),
            ],
            period: 1,
            target: target,
          );
          await game.ensureAdd(target);
          await game.ensureAdd(spawn);

          game.update(1.0);
          game.update(0.0);
          expect(target.children.whereType<PositionComponent>(), hasLength(3));
          expect(
            target.children.query<PositionComponent>().every(
                  (c) => target.toAbsoluteRect().containsPoint(c.position),
                ),
            isTrue,
          );

          game.update(1.0);
          game.update(0.0);
          expect(target.children.whereType<PositionComponent>(), hasLength(6));
          expect(
            target.children.query<PositionComponent>().every(
                  (c) => target.toAbsoluteRect().containsPoint(c.position),
                ),
            isTrue,
          );
        },
      );

      testWithFlameGame(
        'Spawns components with selfPositioning within target bounds',
        (game) async {
          final target = PositionComponent(
            size: Vector2(200, 200),
            position: Vector2(50, 50),
          );
          final spawn = SpawnComponent(
            factory: (_) => PositionComponent(position: Vector2(100, 100)),
            period: 1,
            target: target,
            selfPositioning: true,
          );
          await game.ensureAdd(target);
          await game.ensureAdd(spawn);

          game.update(1.0);
          game.update(0.0);
          expect(target.children.whereType<PositionComponent>(), hasLength(1));
          expect(
            target.children.query<PositionComponent>().every(
                  (c) => c.position == Vector2(100, 100),
                ),
            isTrue,
          );

          game.update(1.0);
          game.update(0.0);
          expect(target.children.whereType<PositionComponent>(), hasLength(2));
          expect(
            target.children.query<PositionComponent>().every(
                  (c) => c.position == Vector2(100, 100),
                ),
            isTrue,
          );
        },
      );

      testWithFlameGame(
        'Throws assertion when target is set without area',
        (game) async {
          final target = Component();

          expectLater(
            game.ensureAdd(
              SpawnComponent(
                factory: (_) => PositionComponent(),
                period: 1,
                target: target,
              ),
            ),
            throwsA(isA<AssertionError>()),
          );
        },
      );
    });
  });
}

class _CountComponent extends PositionComponent {}
