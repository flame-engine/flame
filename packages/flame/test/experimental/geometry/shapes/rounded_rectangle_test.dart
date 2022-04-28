import 'dart:math';
import 'dart:ui';

import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoundedRectangle', () {
    test('simple rounded rectangle', () {
      final rrect = RoundedRectangle.fromLTRBR(4, 0, 9, 12, 2);
      expect(rrect.left, 4);
      expect(rrect.top, 0);
      expect(rrect.right, 9);
      expect(rrect.bottom, 12);
      expect(rrect.radius, 2);
      expect(rrect.width, 5);
      expect(rrect.height, 12);
      expect(rrect.isConvex, true);
      expect(rrect.isClosed, true);
      expect(rrect.perimeter, closeTo(30.566, 0.001));
      expect(rrect.center, closeToVector(6.5, 6));
      expect(
        rrect.aabb,
        closeToAabb(Aabb2.minMax(Vector2(4, 0), Vector2(9, 12))),
      );
      expect('$rrect', 'RoundedRectangle([4.0, 0.0], [9.0, 12.0], 2.0)');
    });

    test('negative radius', () {
      expect(
        () => RoundedRectangle.fromLTRBR(0, 0, 1, 1, -1),
        failsAssert('Radius cannot be negative: -1.0'),
      );
    });

    test('fromPoints', () {
      final rrect = RoundedRectangle.fromPoints(
        Vector2(10, 5),
        Vector2(50, 20),
        5,
      );
      expect(rrect.left, 10);
      expect(rrect.top, 5);
      expect(rrect.right, 50);
      expect(rrect.bottom, 20);
      expect(rrect.radius, 5);
    });

    test('fromRRect', () {
      final rrect = RoundedRectangle.fromRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 0, 50, 100),
          const Radius.circular(15),
        ),
      );
      expect(rrect.left, 20);
      expect(rrect.top, 0);
      expect(rrect.right, 70);
      expect(rrect.bottom, 100);
      expect(rrect.radius, 15);
    });

    test('from bad RRect', () {
      final rrect = RRect.fromLTRBAndCorners(
        0,
        0,
        10,
        10,
        topLeft: const Radius.circular(1),
        topRight: const Radius.circular(1),
        bottomLeft: const Radius.elliptical(1, 2),
        bottomRight: const Radius.circular(1),
      );
      expect(
        () => RoundedRectangle.fromRRect(rrect),
        failsAssert('Unequal radii in the $rrect'),
      );
    });

    test('inverted order of edges', () {
      final rrect = RoundedRectangle.fromLTRBR(5, 6, 1, -1, 2);
      expect(rrect.left, 1);
      expect(rrect.right, 5);
      expect(rrect.top, -1);
      expect(rrect.bottom, 6);
      expect(rrect.radius, 2);
    });

    test('radius too large (horizontally)', () {
      final rrect = RoundedRectangle.fromLTRBR(0, 0, 11, 20, 50);
      expect(rrect.left, 0);
      expect(rrect.right, 11);
      expect(rrect.top, 0);
      expect(rrect.bottom, 20);
      expect(rrect.radius, 5.5);
    });

    test('radius too large (vertically)', () {
      final rrect = RoundedRectangle.fromLTRBR(0, 0, 101, 20, 50);
      expect(rrect.left, 0);
      expect(rrect.right, 101);
      expect(rrect.top, 0);
      expect(rrect.bottom, 20);
      expect(rrect.radius, 10);
    });

    test('asPath()', () {
      final rrect = RoundedRectangle.fromLTRBR(0, 0, 200, 150, 15);
      final path = rrect.asPath();
      final metrics = path.computeMetrics().toList();
      expect(metrics.length, 1);
      expect(metrics.first.length, closeTo(rrect.perimeter, 1.0));
    });

    test('move', () {
      final rrect = RoundedRectangle.fromLTRBR(4, 2, 9, 12, 1);
      expect(rrect.aabb.min, closeToVector(4, 2));
      expect(rrect.aabb.max, closeToVector(9, 12));

      rrect.move(Vector2(-3, 1));
      expect(rrect.left, 4 - 3);
      expect(rrect.right, 9 - 3);
      expect(rrect.top, 2 + 1);
      expect(rrect.bottom, 12 + 1);
      expect(rrect.radius, 1);
      expect(rrect.center, closeToVector(6.5 - 3, 7 + 1));
      expect(
        rrect.aabb,
        closeToAabb(Aabb2.minMax(Vector2(1, 3), Vector2(6, 13))),
      );
    });

    test('containsPoint', () {
      final rrect = RoundedRectangle.fromLTRBR(0, 0, 20, 30, 5);
      expect(rrect.containsPoint(Vector2(0, 0)), false);
      expect(rrect.containsPoint(Vector2(0, 1)), false);
      expect(rrect.containsPoint(Vector2(0, 5)), true);
      expect(rrect.containsPoint(Vector2(10, 15)), true);
      expect(rrect.containsPoint(Vector2(20, 30)), false);
      expect(rrect.containsPoint(Vector2(14, 0)), true);
      expect(rrect.containsPoint(Vector2(20, 10)), true);
      expect(rrect.containsPoint(Vector2(5, 30)), true);
      // points on the rounded corners
      expect(rrect.containsPoint(Vector2(2, 1)), true);
      expect(rrect.containsPoint(Vector2(18, 1)), true);
      expect(rrect.containsPoint(Vector2(1, 28)), true);
      expect(rrect.containsPoint(Vector2(19, 28)), true);
    });

    testRandom('containsPoint random', (Random random) {
      final shape = RoundedRectangle.fromLTRBR(
        random.nextDouble() * 100,
        random.nextDouble() * 100,
        random.nextDouble() * 100,
        random.nextDouble() * 100,
        random.nextDouble() * 5,
      );
      final rrect = shape.asRRect();
      for (var i = 0; i < 100; i++) {
        final point = Vector2.random(random)..scaled(100);
        expect(
          shape.containsPoint(point),
          rrect.contains(point.toOffset()),
        );
      }
    });

    testRandom('support random', (Random random) {
      final rrect = RoundedRectangle.fromLTRBR(0, 0, 20, 30, 5);
      final rect = Rectangle.fromLTRB(5, 5, 15, 25);
      final circle = Circle(Vector2.zero(), 5);
      // In this test we use the fact that `rrect` is the Minkowski sum of the
      // `rect` and the `circle`.
      for (var i = 0; i < 100; i++) {
        final direction = Vector2.random(random);
        final expected = rect.support(direction) + circle.support(direction);
        expect(
          rrect.support(direction),
          closeToVector(expected.x, expected.y, epsilon: 1e-14),
        );
      }
    });

    test('axis-aligned conformal projection', () {
      final rrect = RoundedRectangle.fromLTRBR(3, 3, 15, 12, 1);
      final transform = Transform2D()
        ..position = Vector2(1, 5)
        ..scale = Vector2(4, 4);
      final result = rrect.project(transform);
      expect(result, isA<RoundedRectangle>());
      expect((result as RoundedRectangle).left, 3 * 4 + 1);
      expect(result.right, 15 * 4 + 1);
      expect(result.top, 3 * 4 + 5);
      expect(result.bottom, 12 * 4 + 5);
      expect(result.radius, 1 * 4);
    });

    test('projection with a target', () {
      final rrect = RoundedRectangle.fromLTRBR(3, 3, 15, 12, 1);
      final transform = Transform2D()
        ..position = Vector2(1, 5)
        ..scale = Vector2(4, 4);
      final target = RoundedRectangle.fromLTRBR(0, 0, 0, 0, 0);
      expect(target.aabb, closeToAabb(Aabb2()));
      final result = rrect.project(transform, target);
      expect(result, isA<RoundedRectangle>());
      expect(result, target);
      expect(target.left, 3 * 4 + 1);
      expect(target.right, 15 * 4 + 1);
      expect(target.top, 3 * 4 + 5);
      expect(target.bottom, 12 * 4 + 5);
      expect(target.radius, 1 * 4);
      expect(
        target.aabb,
        closeToAabb(Aabb2.minMax(Vector2(13, 17), Vector2(61, 53))),
      );
    });

    test('unsupported projection', () {
      final rrect = RoundedRectangle.fromLTRBR(3, 3, 15, 12, 1);
      final transform = Transform2D()
        ..position = Vector2(1, 5)
        ..scale = Vector2(2, 4);
      expect(
        () => rrect.project(transform),
        throwsUnimplementedError,
      );
    });
  });
}
