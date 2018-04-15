import 'package:test/test.dart';
import 'dart:math' as math;

import 'package:flame/position.dart';

void expectDouble(double d1, double d2) {
  expect((d1 - d2).abs() <= 0.0001, true);
}

void main() {
  group('position test', () {
    test('test add', () {
      Position p = new Position(0.0, 5.0);
      Position p2 = p.add(new Position(5.0, 5.0));
      expect(p, p2);
      expectDouble(p.x, 5.0);
      expectDouble(p.y, 10.0);
    });

    test('test clone', () {
      Position p = new Position(1.0, 0.0);
      Position clone = p.clone();

      clone.times(2.0);
      expectDouble(p.x, 1.0);
      expectDouble(clone.x, 2.0);
    });

    test('test rotate', () {
      Position p = new Position(1.0, 0.0).rotate(math.pi / 2);
      expectDouble(p.x, 0.0);
      expectDouble(p.y, 1.0);
    });

    test('test length', () {
      Position p = new Position(3.0, 4.0);
      expectDouble(p.length(), 5.0);
    });
  });
}
