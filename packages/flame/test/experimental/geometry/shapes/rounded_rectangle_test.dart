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
  });
}
