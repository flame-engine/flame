import 'package:test/test.dart';
import 'dart:math' as math;

import 'package:flame/vector2d.dart';

void expectDouble(double d1, double d2) {
  expect((d1 - d2).abs() <= 0.0001, true);
}

void main() {
  group('position test', () {
    test('test add', () {
      final Vector2d p = Vector2d(0.0, 5.0);
      final Vector2d p2 = p.add(Vector2d(5.0, 5.0));
      expect(p, p2);
      expectDouble(p.x, 5.0);
      expectDouble(p.y, 10.0);
    });

    test('test clone', () {
      final Vector2d p = Vector2d(1.0, 0.0);
      final Vector2d clone = p.clone();

      clone.times(2.0);
      expectDouble(p.x, 1.0);
      expectDouble(clone.x, 2.0);
    });

    test('test rotate', () {
      final Vector2d p = Vector2d(1.0, 0.0).rotate(math.pi / 2);
      expectDouble(p.x, 0.0);
      expectDouble(p.y, 1.0);
    });

    test('test length', () {
      final Vector2d p1 = Vector2d(3.0, 4.0);
      expectDouble(p1.length(), 5.0);

      final Vector2d p2 = Vector2d(2.0, 0.0);
      expectDouble(p2.length(), 2.0);

      final Vector2d p3 = Vector2d(0.0, 1.5);
      expectDouble(p3.length(), 1.5);
    });

    test('test distance', () {
      final Vector2d p1 = Vector2d(10.0, 20.0);
      final Vector2d p2 = Vector2d(13.0, 24.0);
      final double result = p1.distance(p2);
      expectDouble(result, 5.0);
    });

    test('equality', () {
      final Vector2d p1 = Vector2d.zero();
      final Vector2d p2 = Vector2d.zero();
      expect(p1 == p2, true);
    });

    test('non equality', () {
      final Vector2d p1 = Vector2d.zero();
      final Vector2d p2 = Vector2d(1.0, 0.0);
      expect(p1 == p2, false);
    });

    test('hashCode', () {
      final Vector2d p1 = Vector2d(2.0, -1.0);
      final Vector2d p2 = Vector2d(1.0, 0.0);
      expect(p1.hashCode == p2.hashCode, false);
    });

    test('scaleTo', () {
      final Vector2d p = Vector2d(1.0, 0.0);

      p.rotate(math.pi / 4).scaleTo(2.0);
      expect(p.length(), 2.0);

      p.rotate(-math.pi / 4);
      expect(p.length(), 2.0);
      expect(p.x, 2.0);
      expect(p.y, 0.0);
    });

    test('scaleTo the zero vector', () {
      final Vector2d p = Vector2d.zero();
      expect(p.scaleTo(1.0).length(), 0.0);
    });

    test('limit', () {
      final Vector2d p1 = Vector2d(1.0, 0.0);
      p1.limit(0.75);
      expect(p1.length(), 0.75);
      expect(p1.x, 0.75);
      expect(p1.y, 0.0);

      final Vector2d p2 = Vector2d(1.0, 1.0);
      p2.limit(3.0);
      expectDouble(p2.length(), math.sqrt(2));
      expect(p2.x, 1.0);
      expect(p2.y, 1.0);
      p2.limit(1.0);
      expectDouble(p2.length(), 1.0);
      expect(p2.x, p2.y);
    });
  });
}
