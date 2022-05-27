import 'dart:math';

import 'package:flame/src/utils/solve_quadratic.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('solveQuadratic', () {
    testRandom('solve equation with 2 roots', (rnd) {
      final x1 = rnd.nextDouble() * 5 - 1;
      final x2 = rnd.nextDouble() * 0.3 - 0.2;
      final a = rnd.nextDouble();
      final b = (-x1 - x2) * a;
      final c = x1 * x2 * a;
      final solutions = solveQuadratic(a, b, c)..sort();
      expect(solutions.length, 2);
      expect(solutions[0], closeTo(min(x1, x2), 1e-10));
      expect(solutions[1], closeTo(max(x1, x2), 1e-10));
    });

    testRandom('solve equation with 1 root', (rnd) {
      final x1 = rnd.nextDouble();
      final b = -2 * x1;
      final c = x1 * x1;
      final solutions = solveQuadratic(1, b, c);
      expect(solutions.length, 1);
      expect(solutions[0], closeTo(x1, 1e-10));
    });

    testRandom('solve equation with no roots', (rnd) {
      final x1 = rnd.nextDouble();
      final b = -2 * x1;
      final c = x1 * x1 + rnd.nextDouble().abs() * 0.1;
      final solutions = solveQuadratic(1, b, c);
      expect(solutions.length, 0);
    });

    test('solve degenerate equation', () {
      expect(solveQuadratic(0, 1, 5), [-5]);
      expect(solveQuadratic(double.minPositive, -2, 5), [2.5]);
      expect(solveQuadratic(-double.minPositive, -2, 5), [2.5]);
    });
  });
}
