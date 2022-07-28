import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

void main() {
  group('Sweep', () {
    group('raycast', () {
      testCollisionDetectionGame('detects CircleHitbox', (game) async {
        final circleHitbox = CircleHitbox();
        game.add(
          PositionComponent(
            position: Vector2.all(100),
            size: Vector2.all(10),
          )..add(circleHitbox),
        );
        await game.ready();
        final ray = Ray2(Vector2.zero(), Vector2.all(1)..normalize());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).first, circleHitbox);
      });

      testCollisionDetectionGame('detects RectangleHitbox', (game) async {
        final rectangleHitbox = RectangleHitbox();
        game.add(
          PositionComponent(
            position: Vector2.all(100),
            size: Vector2.all(10),
          )..add(rectangleHitbox),
        );
        await game.ready();
        final ray = Ray2(Vector2.zero(), Vector2.all(1)..normalize());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).first, rectangleHitbox);
      });

      testCollisionDetectionGame(
        'detects RectangleHitbox with ray from above',
        (game) async {
          final rectangleHitbox = RectangleHitbox();
          game.add(
            PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
            )..add(rectangleHitbox),
          );
          await game.ready();
          final ray = Ray2(Vector2(5, -5), Vector2(0, 1));
          final sweep = game.collisionDetection.broadphase;
          expect(sweep.raycast(ray).firstOrNull, rectangleHitbox);
        },
      );

      testCollisionDetectionGame(
        'detects RectangleHitbox with ray from below',
        (game) async {
          final rectangleHitbox = RectangleHitbox();
          game.add(
            PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
            )..add(rectangleHitbox),
          );
          await game.ready();
          final ray = Ray2(Vector2(5, 15), Vector2(0, -1));
          final sweep = game.collisionDetection.broadphase;
          expect(sweep.raycast(ray).firstOrNull, rectangleHitbox);
        },
      );

      testCollisionDetectionGame(
        'detects RectangleHitbox with ray from the left',
        (game) async {
          final rectangleHitbox = RectangleHitbox();
          game.add(
            PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
            )..add(rectangleHitbox),
          );
          await game.ready();
          final ray = Ray2(Vector2(-5, 5), Vector2(1, 0));
          final sweep = game.collisionDetection.broadphase;
          expect(sweep.raycast(ray).firstOrNull, rectangleHitbox);
        },
      );

      testCollisionDetectionGame(
        'detects RectangleHitbox with ray from the right',
        (game) async {
          final rectangleHitbox = RectangleHitbox();
          game.add(
            PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
            )..add(rectangleHitbox),
          );
          await game.ready();
          final ray = Ray2(Vector2(15, 5), Vector2(-1, 0));
          final sweep = game.collisionDetection.broadphase;
          expect(sweep.raycast(ray).firstOrNull, rectangleHitbox);
        },
      );

      testCollisionDetectionGame(
        'detects CircleHitbox with ray from above',
        (game) async {
          final circleHitbox = CircleHitbox();
          game.add(
            PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
            )..add(circleHitbox),
          );
          await game.ready();
          final ray = Ray2(Vector2(5, -5), Vector2(0, 1));
          final sweep = game.collisionDetection.broadphase;
          expect(sweep.raycast(ray).firstOrNull, circleHitbox);
        },
      );

      testCollisionDetectionGame(
        'detects CircleHitbox with ray from below',
        (game) async {
          final circleHitbox = CircleHitbox();
          game.add(
            PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
            )..add(circleHitbox),
          );
          await game.ready();
          final ray = Ray2(Vector2(5, 15), Vector2(0, -1));
          final sweep = game.collisionDetection.broadphase;
          expect(sweep.raycast(ray).firstOrNull, circleHitbox);
        },
      );

      testCollisionDetectionGame(
        'detects CircleHitbox with ray from the left',
        (game) async {
          final circleHitbox = CircleHitbox();
          game.add(
            PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
            )..add(circleHitbox),
          );
          await game.ready();
          final ray = Ray2(Vector2(-5, 5), Vector2(1, 0));
          final sweep = game.collisionDetection.broadphase;
          expect(sweep.raycast(ray).firstOrNull, circleHitbox);
        },
      );

      testCollisionDetectionGame(
        'detects CircleHitbox with ray from the right',
        (game) async {
          final circleHitbox = CircleHitbox();
          game.add(
            PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
            )..add(circleHitbox),
          );
          await game.ready();
          final ray = Ray2(Vector2(15, 5), Vector2(-1, 0));
          final sweep = game.collisionDetection.broadphase;
          expect(sweep.raycast(ray).firstOrNull, circleHitbox);
        },
      );

      testCollisionDetectionGame('detects PolygonHitbox', (game) async {
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
        final ray = Ray2(Vector2.zero(), Vector2.all(1)..normalize());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).first, polygonHitbox);
      });

      testCollisionDetectionGame('empty list on no results', (game) async {
        final circleHitbox = CircleHitbox();
        game.add(
          PositionComponent(
            position: Vector2.all(100),
            size: Vector2.all(10),
          )..add(circleHitbox),
        );
        await game.ready();
        final ray = Ray2(Vector2.zero(), Vector2.all(-1)..normalize());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).isEmpty, isTrue);
      });

      testCollisionDetectionGame('detects multiple hitboxes', (game) async {
        game.addAll([
          for (var i = 0.0; i < 10; i++)
            PositionComponent(
              position: Vector2.all(100 + i * 10),
              size: Vector2.all(20 - i),
            )..add(CircleHitbox()),
        ]);
        await game.ready();
        final ray = Ray2(Vector2.zero(), Vector2.all(1)..normalize());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).length, game.children.length);
      });

      testCollisionDetectionGame('detects correct collision among two hitboxes',
          (game) async {
        final rectangle1 = RectangleComponent(
          position: Vector2.all(20),
          size: Vector2.all(20),
          anchor: Anchor.center,
        )..add(RectangleHitbox());
        final rectangle2 = RectangleComponent(
          position: Vector2(-20, 40),
          size: Vector2.all(20),
          anchor: Anchor.center,
        )..add(RectangleHitbox());
        await game.ensureAddAll([rectangle1, rectangle2]);
        final ray = Ray2(Vector2(0, 10), Vector2(-1, 1)..normalize());
        final sweep = game.collisionDetection.broadphase;
        expect(sweep.raycast(ray).length, 1);
        expect(sweep.raycast(ray).first, rectangle2.children.first);
      });
    });
  });
}
