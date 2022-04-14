import 'dart:math';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Circle', () {
    test('simple properties', () {
      final circle = Circle(Vector2(5, 10), 2.5);
      expect(circle.isClosed, true);
      expect(circle.isConvex, true);
      expect(circle.center, closeToVector(5, 10));
      expect(circle.radius, 2.5);
      expect(circle.perimeter, 2 * 2.5 * pi);
      expect('$circle', 'Circle([5.0, 10.0], 2.5)');
    });

    test('invalid circles', () {
      expect(
        () => Circle(Vector2.zero(), 0),
        failsAssert('Radius must be positive: 0.0'),
      );
      expect(
        () => Circle(Vector2.zero(), -1),
        failsAssert('Radius must be positive: -1.0'),
      );
    });

    test('aabb', () {
      final circle = Circle(Vector2(-3, 14), 2.0);
      expect(
        circle.aabb,
        closeToAabb(Aabb2.minMax(Vector2(-5, 12), Vector2(-1, 16))),
      );
    });

    testRandom('containsPoint', (Random random) {
      final center = Vector2(5, 12);
      const radius = 2.5;
      final circle = Circle(center, radius);
      for (var i = 0; i < 100; i++) {
        final point = (Vector2.random(random) - Vector2.all(0.5)) * 9 + center;
        final inside = (point - center).length <= radius;
        expect(circle.containsPoint(point), inside);
      }
      expect(circle.containsPoint(Vector2(7.5, 12)), true);
      expect(circle.containsPoint(Vector2(2.5, 12)), true);
      expect(circle.containsPoint(Vector2(5, 14.5)), true);
      expect(circle.containsPoint(Vector2(5, 9.5)), true);
      expect(circle.containsPoint(Vector2(5 + 1.5, 12 + 2)), true);
    });

    test('move', () {
      final circle = Circle(Vector2.zero(), 1);
      expect(circle.center, closeToVector(0, 0));
      expect(circle.radius, 1);
      expect(
        circle.aabb,
        closeToAabb(Aabb2.minMax(Vector2(-1, -1), Vector2(1, 1))),
      );

      circle.move(Vector2(4, 7));
      expect(circle.center, closeToVector(4, 7));
      expect(circle.radius, 1);
      expect(
        circle.aabb,
        closeToAabb(Aabb2.minMax(Vector2(3, 6), Vector2(5, 8))),
      );
    });

    test('asPath', () {
      final circle = Circle(Vector2(30, 40), 100);
      final path = circle.asPath();
      final metrics = path.computeMetrics().toList();
      expect(metrics.length, 1);
      expect(metrics[0].isClosed, true);
      expect(metrics[0].length, closeTo(circle.perimeter, 1.5));
    });

    test('project', () {
      final circle = Circle(Vector2.zero(), 100);
      final transform = Transform2D()..position = Vector2(10, 40);
      final result = circle.project(transform);
      expect(result, isA<Circle>());
      expect(result.center, closeToVector(10, 40));
      expect((result as Circle).radius, 100);

      transform.scale.setValues(1, 2);
      expect(
        () => circle.project(transform),
        throwsUnimplementedError,
      );
    });

    test('project with target', () {
      final circle = Circle(Vector2.zero(), 100);
      final target = Circle(Vector2.zero(), 1);
      final transform = Transform2D()
        ..position = Vector2(10, 20)
        ..angle = 1
        ..scale = Vector2.all(-2);
      expect(transform.isConformal, true);

      final result = circle.project(transform, target);
      expect(result, isA<Circle>());
      expect(result, target);
      expect(target.radius, 200);
      expect(target.center, closeToVector(10, 20));
    });
  });
}
