import 'dart:math';
import 'package:flame/src/geometry/shapes/circle.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

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

    test('aabbs', () {
      final circle = Circle(Vector2(-3, 14), 2.0);
      // expect(circle.aabb, Aabb2.minMax(Vector2(-5, 12), Vector2(-1, 16)));
    });
  });
}
