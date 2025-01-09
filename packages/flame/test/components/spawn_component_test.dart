import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
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
  });
}
