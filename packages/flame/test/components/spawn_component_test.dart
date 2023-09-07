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
        factory: PositionComponent.new,
        period: 1,
        area: shape,
        random: random,
      );
      await game.ensureAdd(spawn);
      game.update(0.5);
      expect(game.children.length, 1);
      game.update(0.5);
      game.update(0.0);
      expect(game.children.length, 2);
      game.update(1.0);
      game.update(0.0);
      expect(game.children.length, 3);

      for (var i = 0; i < 1000; i++) {
        game.update(random.nextDouble());
      }
      expect(
        game.children
            .query<PositionComponent>()
            .every((c) => shape.containsPoint(c.position)),
        isTrue,
      );
    });

    testWithFlameGame('Spawns components within circle', (game) async {
      final random = Random(0);
      final shape = Circle(Vector2(100, 200), 100);
      expect(shape.containsPoint(Vector2.all(200)), isTrue);
      final spawn = SpawnComponent(
        factory: PositionComponent.new,
        period: 1,
        area: shape,
        random: random,
      );
      await game.ensureAdd(spawn);
      game.update(0.5);
      expect(game.children.length, 1);
      game.update(0.5);
      game.update(0.0);
      expect(game.children.length, 2);
      game.update(1.0);
      game.update(0.0);
      expect(game.children.length, 3);

      for (var i = 0; i < 1000; i++) {
        game.update(random.nextDouble());
      }
      expect(
        game.children
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
        factory: PositionComponent.new,
        period: 1,
        area: shape,
        random: random,
      );
      await game.ensureAdd(spawn);
      game.update(0.5);
      expect(game.children.length, 1);
      game.update(0.5);
      game.update(0.0);
      expect(game.children.length, 2);
      game.update(1.0);
      game.update(0.0);
      expect(game.children.length, 3);

      for (var i = 0; i < 1000; i++) {
        game.update(random.nextDouble());
      }
      expect(
        game.children
            .query<PositionComponent>()
            .every((c) => shape.containsPoint(c.position)),
        isTrue,
      );
    });
  });
}
