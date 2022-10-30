import 'dart:math';

import 'package:flame/src/utils/solve_quadratic.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('solveQuadratic', () {
    const repeatCount = 3;

    testRandom(
      'solve equation with 2 roots',
      (Random rnd) {
        final x1 = rnd.nextDouble() * 5 - 1;
        final x2 = rnd.nextDouble() * 0.3 - 0.2;
        final a = rnd.nextDouble();
        final b = (-x1 - x2) * a;
        final c = x1 * x2 * a;
        final solutions = solveQuadratic(a, b, c)..sort();
        expect(solutions.length, 2);
        expect(solutions[0], closeTo(min(x1, x2), 1e-10));
        expect(solutions[1], closeTo(max(x1, x2), 1e-10));
      },
      repeatCount: repeatCount,
    );

    testRandom(
      'solve equation with 1 double root',
      (Random rnd) {
        final x1 = rnd.nextDouble();
        final b = -2 * x1;
        final c = x1 * x1;
        final solutions = solveQuadratic(1, b, c);
        expect(solutions.length, 2);
        expect(solutions[0], closeTo(x1, 1e-10));
        expect(solutions[1], closeTo(x1, 1e-10));
      },
      repeatCount: repeatCount,
    );

    testRandom(
      'solve equation with no roots',
      (Random rnd) {
        final x1 = rnd.nextDouble();
        final b = -2 * x1;
        final c = x1 * x1 + rnd.nextDouble().abs() * 0.1;
        final solutions = solveQuadratic(1, b, c);
        expect(solutions.length, 0);
      },
      repeatCount: repeatCount,
    );

    testRandom(
      'solve random equation',
      (Random rnd) {
        final a = rnd.nextDouble();
        final b = rnd.nextDouble() * 2;
        final c = rnd.nextDouble() * 4;
        final solutions = solveQuadratic(a, b, c);
        for (final x in solutions) {
          expect(a * x * x + b * x + c, closeTo(0, 1e-15 / a));
        }
      },
      repeatCount: repeatCount,
    );

    test('solve degenerate equations', () {
      expect(solveQuadratic(0, 1, 5), [-5]);
      expect(solveQuadratic(0, -2, 5), [2.5]);
      expect(solveQuadratic(1e-314, -2, 5), [0, double.infinity]);
    });
  });
}
