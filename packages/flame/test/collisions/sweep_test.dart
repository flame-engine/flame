import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

void main() {
  group('Sweep', () {
    group('raycast', () {
      testCollidableGame('detects CircleHitbox', (game) async {
        final circleHitbox = CircleHitbox();
        game.add(
          PositionComponent(
            position: Vector2.all(100),
            size: Vector2.all(10),
          )..add(circleHitbox),
        );
        await game.ready();
        final ray = Ray2(Vector2.zero(), Vector2.all(1)..normalized());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).first.hitbox, circleHitbox);
      });

      testCollidableGame('detects RectangleHitbox', (game) async {
        final rectangleHitbox = RectangleHitbox();
        game.add(
          PositionComponent(
            position: Vector2.all(100),
            size: Vector2.all(10),
          )..add(rectangleHitbox),
        );
        await game.ready();
        final ray = Ray2(Vector2.zero(), Vector2.all(1)..normalized());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).first.hitbox, rectangleHitbox);
      });

      testCollidableGame('detects PolygonHitbox', (game) async {
        final polygonHitbox = PolygonHitbox([
          Vector2(1, 0),
          Vector2(0, 1),
          Vector2(-1, 0),
          Vector2(0, -1),
        ]);
        game.add(
          PositionComponent(
            position: Vector2.all(100),
            size: Vector2.all(10),
          )..add(polygonHitbox),
        );
        await game.ready();
        final ray = Ray2(Vector2.zero(), Vector2.all(1)..normalized());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).first.hitbox, polygonHitbox);
      });

      testCollidableGame('empty list on no results', (game) async {
        final circleHitbox = CircleHitbox();
        game.add(
          PositionComponent(
            position: Vector2.all(100),
            size: Vector2.all(10),
          )..add(circleHitbox),
        );
        await game.ready();
        final ray = Ray2(Vector2.zero(), Vector2.all(-1)..normalized());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).isEmpty, isTrue);
      });

      testCollidableGame('detects multiple hitboxes', (game) async {
        game.addAll([
          for (var i = 0.0; i < 10; i++)
            PositionComponent(
              position: Vector2.all(100 + i * 10),
              size: Vector2.all(20 - i),
            )..add(CircleHitbox()),
        ]);
        await game.ready();
        final ray = Ray2(Vector2.zero(), Vector2.all(1)..normalized());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).length, game.children.length);
      });
    });
  });
}
