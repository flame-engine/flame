import 'package:test/test.dart';
import 'dart:math' as math;

import 'package:flame/position.dart';

void expectDouble(double d1, double d2) {
  expect((d1 - d2).abs() <= 0.0001, true);
}

void main() {
  group('position test', () {
    test('test add', () {
      final Position p = Position(0.0, 5.0);
      final Position p2 = p.add(Position(5.0, 5.0));
      expect(p, p2);
      expectDouble(p.x, 5.0);
      expectDouble(p.y, 10.0);
    });

    test('test clone', () {
      final Position p = Position(1.0, 0.0);
      final Position clone = p.clone();

      clone.times(2.0);
      expectDouble(p.x, 1.0);
      expectDouble(clone.x, 2.0);
    });

    test('test rotate', () {
      final Position p = Position(1.0, 0.0).rotate(math.pi / 2);
      expectDouble(p.x, 0.0);
      expectDouble(p.y, 1.0);
    });

    test('test length', () {
      final Position p1 = Position(3.0, 4.0);
      expectDouble(p1.length(), 5.0);

      final Position p2 = Position(2.0, 0.0);
      expectDouble(p2.length(), 2.0);

      final Position p3 = Position(0.0, 1.5);
      expectDouble(p3.length(), 1.5);
    });

    test('test distance', () {
      final Position p1 = Position(10.0, 20.0);
      final Position p2 = Position(13.0, 24.0);
      final double result = p1.distance(p2);
      expectDouble(result, 5.0);
    });

    test('equality', () {
      final Position p1 = Position.empty();
      final Position p2 = Position.empty();
      expect(p1 == p2, true);
    });

    test('non equality', () {
      final Position p1 = Position.empty();
      final Position p2 = Position(1.0, 0.0);
      expect(p1 == p2, false);
    });

    test('hashCode', () {
      final Position p1 = Position(2.0, -1.0);
      final Position p2 = Position(1.0, 0.0);
      expect(p1.hashCode == p2.hashCode, false);
    });

    test('scaleTo', () {
      final Position p = Position(1.0, 0.0);

      p.rotate(math.pi / 4).scaleTo(2.0);
      expect(p.length(), 2.0);

      p.rotate(-math.pi / 4);
      expect(p.length(), 2.0);
      expect(p.x, 2.0);
      expect(p.y, 0.0);
    });

    test('scaleTo the zero vector', () {
      final Position p = Position.empty();
      expect(p.scaleTo(1.0).length(), 0.0);
    });

    test('limit', () {
      final Position p1 = Position(1.0, 0.0);
      p1.limit(0.75);
      expect(p1.length(), 0.75);
      expect(p1.x, 0.75);
      expect(p1.y, 0.0);

      final Position p2 = Position(1.0, 1.0);
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
