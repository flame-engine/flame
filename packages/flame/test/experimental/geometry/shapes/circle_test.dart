import 'dart:math';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Circle', () {
    test('simple properties', () {
      final center = Vector2(5, 10);
      final circle = Circle(center, 2.5);
      expect(circle.isClosed, true);
      expect(circle.isConvex, true);
      expect(circle.center, center);
      expect(circle.radius, 2.5);
      expect(circle.perimeter, 2 * pi * 2.5);
      expect('$circle', 'Circle([5.0, 10.0], 2.5)');
      // Modifying original `center` vector does not affect the shape
      center.x += 111;
      expect(circle.center, closeToVector(Vector2(5, 10)));
    });

    test('negative radius', () {
      expect(
        () => Circle(Vector2.zero(), -1),
        failsAssert('Radius cannot be negative: -1.0'),
      );
    });

    test('zero-radius circle', () {
      final center = Vector2(3, 5);
      final circle = Circle(center, 0);
      expect(circle.radius, 0);
      expect(circle.center, center);
      expect(circle.containsPoint(center), true);
      expect(circle.perimeter, 0);
      expect(circle.support(Vector2(1, 1)), center);
      expect(circle.support(Vector2(-2, 10)), center);
      expect(circle.aabb, closeToAabb(Aabb2.minMax(center, center)));
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
      expect(circle.center, closeToVector(Vector2.zero()));
      expect(circle.radius, 1);
      expect(
        circle.aabb,
        closeToAabb(Aabb2.minMax(Vector2(-1, -1), Vector2(1, 1))),
      );

      circle.move(Vector2(4, 7));
      expect(circle.center, closeToVector(Vector2(4, 7)));
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

    test('0-radius circle asPath', () {
      final circle = Circle(Vector2.zero(), 0);
      final path = circle.asPath();
      final metrics = path.computeMetrics().toList();
      expect(metrics.isEmpty, true);
    });

    test('project', () {
      final circle = Circle(Vector2.zero(), 100);
      final transform = Transform2D()..position = Vector2(10, 40);
      final result = circle.project(transform);
      expect(result, isA<Circle>());
      expect(result.center, closeToVector(Vector2(10, 40)));
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
      expect(target.center, closeToVector(Vector2(10, 20)));
    });

    test('support', () {
      final circle = Circle(Vector2(2, 1), 10);
      expect(circle.support(Vector2(1, 0)), closeToVector(Vector2(12, 1)));
      expect(circle.support(Vector2(-1, 0)), closeToVector(Vector2(-8, 1)));
      expect(circle.support(Vector2(0, 3.14)), closeToVector(Vector2(2, 11)));
      expect(circle.support(Vector2(0, -3)), closeToVector(Vector2(2, -9)));
      expect(
        circle.support(Vector2(1, 1)),
        closeToVector(Vector2(2 + 10 / sqrt(2), 1 + 10 / sqrt(2))),
      );
      expect(
        circle.support(Vector2(3, 4)),
        closeToVector(Vector2(2 + 6, 1 + 8)),
      );
      expect(
        circle.support(Vector2(-2, -1)),
        closeToVector(Vector2(2 - 20 / sqrt(5), 1 - 10 / sqrt(5))),
      );
    });

    test('nearestPoint', () {
      final circle = Circle(Vector2(1, 1), 1);
      const a = 0.7071067811865475; // sqrt(1/2)
      expect(circle.nearestPoint(Vector2(0, 0)), Vector2.all(1 - a));
      expect(circle.nearestPoint(Vector2(1, 0)), Vector2(1, 0));
      expect(circle.nearestPoint(Vector2(2, 0)), Vector2(1 + a, 1 - a));
      expect(circle.nearestPoint(Vector2(2, 2)), Vector2(1 + a, 1 + a));
    });

    test('nearestPoint for zero-radius circle', () {
      final circle = Circle(Vector2(3, 4), 0);
      expect(circle.nearestPoint(Vector2(3, 4)), Vector2(3, 4));
      expect(circle.nearestPoint(Vector2(5, 7)), Vector2(3, 4));
      expect(circle.nearestPoint(Vector2(0, 0)), Vector2(3, 4));
    });

    test('nearestPoint object ownership', () {
      final circle = Circle(Vector2(3, 4), 5);
      final point1 = Vector2(10, 20);
      final point2 = Vector2(-3, -4);
      final result1 = circle.nearestPoint(point1);
      final result2 = circle.nearestPoint(point2);

      // This checks that nearestPoint() does not modify its argument.
      expect(point1, Vector2(10, 20));
      expect(point2, Vector2(-3, -4));
      // at this point result1 can have any value...
      expect(result1, isNotNull);
      expect(result2, Vector2(0, 0));
    });

    test('fromPoints', () {
      final p1 = Vector2.zero();
      final p2 = Vector2(0, 1);
      final p3 = Vector2(1, 0);

      final circle = Circle.fromPoints(p1, p2, p3)!;
      expect(circle.center, Vector2.all(0.5));
      expectDouble(circle.radius, 1 / sqrt(2));

      expect(circle.containsPoint(p1), true);
      expect(circle.containsPoint(p2), true);
      expect(circle.containsPoint(p3), true);
    });
  });
}
