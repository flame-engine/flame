import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:test/test.dart';

void expectDouble(double d1, double d2) {
  expect((d1 - d2).abs() <= 0.0001, true);
}

void main() {
  group('Vector2 test', () {
    test('test add', () {
      final p = Vector2(0.0, 5.0) + Vector2(5.0, 5.0);
      expectDouble(p.x, 5.0);
      expectDouble(p.y, 10.0);
    });

    test('test clone', () {
      final p = Vector2(1.0, 0.0);
      final clone = p.clone();

      clone.scale(2.0);
      expectDouble(p.x, 1.0);
      expectDouble(clone.x, 2.0);
    });

    test('test rotate', () {
      final p = Vector2(1.0, 0.0)..rotate(math.pi / 2);
      expectDouble(p.x, 0.0);
      expectDouble(p.y, 1.0);
    });

    test('test length', () {
      final p1 = Vector2(3.0, 4.0);
      expectDouble(p1.length, 5.0);

      final p2 = Vector2(2.0, 0.0);
      expectDouble(p2.length, 2.0);

      final p3 = Vector2(0.0, 1.5);
      expectDouble(p3.length, 1.5);
    });

    test('test distance', () {
      final p1 = Vector2(10.0, 20.0);
      final p2 = Vector2(13.0, 24.0);
      final result = p1.distanceTo(p2);
      expectDouble(result, 5.0);
    });

    test('equality', () {
      final p1 = Vector2.zero();
      final p2 = Vector2.zero();
      expect(p1 == p2, true);
    });

    test('non equality', () {
      final p1 = Vector2.zero();
      final p2 = Vector2(1.0, 0.0);
      expect(p1 == p2, false);
    });

    test('hashCode', () {
      final p1 = Vector2(2.0, -1.0);
      final p2 = Vector2(1.0, 0.0);
      expect(p1.hashCode == p2.hashCode, false);
    });

    test('scaleTo', () {
      final p = Vector2(1.0, 0.0)
        ..rotate(math.pi / 4)
        ..scaleTo(2.0);

      expect(p.length, 2.0);

      p.rotate(-math.pi / 4);
      expect(p.length, 2.0);
      expect(p.x, 2.0);
      expect(p.y, 0.0);
    });

    test('scaleTo the zero vector', () {
      final p = Vector2.zero();
      expect(p.normalized().length, 0.0);
    });

    test('limit', () {
      final p1 = Vector2(1.0, 0.0);
      p1.clampScalar(0, 0.75);
      expect(p1.length, 0.75);
      expect(p1.x, 0.75);
      expect(p1.y, 0.0);

      final p2 = Vector2(1.0, 1.0);
      p2.clampScalar(0, 3.0);
      expectDouble(p2.length, math.sqrt(2));
      expect(p2.x, 1.0);
      expect(p2.y, 1.0);
      p2.clampScalar(0, 1.0);
      expectDouble(p2.length, math.sqrt(2));
      expect(p2.x, p2.y);
    });
  });
}
