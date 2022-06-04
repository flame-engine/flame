import 'package:flame/src/utils/solve_cubic.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('solveCubic', () {
    const repeatCount = 3;

    testRandom(
      'solve equation with 3 roots',
      (rnd) {
        final x1 = rnd.nextDouble() * 5 - 1;
        final x2 = rnd.nextDouble() * 0.3 - 0.2;
        final x3 = rnd.nextDouble() * 2 - 1;
        // a(x - x1)(x - x2)(x - x3) == 0
        final a = rnd.nextDouble() + 1e-6;
        final b = -(x1 + x2 + x3) * a;
        final c = (x1 * x2 + x2 * x3 + x3 * x1) * a;
        final d = -x1 * x2 * x3 * a;
        final solutions = solveCubic(a, b, c, d);
        if (((x1 - x2) * (x2 - x3) * (x3 - x1)).abs() > 1e-5) {
          check(solutions, [x1, x2, x3]);
        }
      },
      repeatCount: repeatCount,
    );

    testRandom(
      'solve equation with 2 roots',
      (rnd) {
        final x1 = rnd.nextDouble() * 5 - 1;
        final x2 = rnd.nextDouble() * 0.3 - 0.2;
        // a(x - x1)(x - x2)² == 0
        final a = rnd.nextDouble();
        final b = -(x1 + x2 + x2) * a;
        final c = (2 * x1 * x2 + x2 * x2) * a;
        final d = -x1 * x2 * x2 * a;
        final solutions = solveCubic(a, b, c, d);
        if (solutions.length == 1) {
          check(solutions, [x1]);
        } else {
          check(solutions, [x1, x2, x2]);
        }
      },
      repeatCount: repeatCount,
    );

    test('solve equation with 1 triple root', () {
      check(solveCubic(1, -3, 3, -1), [1, 1, 1]);
      check(solveCubic(10, 30, 30, 10), [-1, -1, -1]);
      const x = 2.78;
      check(solveCubic(1, -3 * x, 3 * x * x, -x * x * x), [x, x, x]);
    });

    testRandom(
      'solve equation with 1 real root',
      (rnd) {
        final x1 = rnd.nextDouble() * 5 - 1;
        final x2 = rnd.nextDouble() * 0.3 - 0.2;
        // a(x - x1)((x - x2)² + 0.5) == 0
        final a = rnd.nextDouble();
        final b = -(x1 + 2 * x2) * a;
        final c = (2 * x1 * x2 + x2 * x2 + 0.5) * a;
        final d = -x1 * (x2 * x2 + 0.5) * a;
        final solutions = solveCubic(a, b, c, d);
        check(solutions, [x1]);
      },
      repeatCount: repeatCount,
    );

    test('solve degenerate equation', () {
      check(solveCubic(0, 1, 2, 1), [-1, -1]);
      check(solveCubic(0, 0, 1, 3), [-3]);
    });

    test('solve depressed equation', () {
      check(solveCubic(1, 0, -7, 6), [1, 2, -3]);
      check(solveCubic(0.1, 0, -0.7, -0.6), [-1, -2, 3]);
    });

    testRandom(
      'solve random equation',
      (rnd) {
        final a = rnd.nextDouble();
        final b = rnd.nextDouble() * 2;
        final c = rnd.nextDouble() * 4;
        final d = rnd.nextDouble() * 6;
        final solutions = solveCubic(a, b, c, d);
        for (final x in solutions) {
          expect(a * x * x * x + b * x * x + c * x + d, closeTo(0, 1e-6));
        }
      },
      repeatCount: repeatCount,
    );
  });
}

void check(List<double> list1, List<double> list2) {
  expect(
    list1.length,
    equals(list2.length),
    reason: 'solutions are: $list1 vs $list2',
  );
  list1.sort();
  list2.sort();
  for (var i = 0; i < list1.length; i++) {
    expect(list1[i], closeTo(list2[i], 1e-6));
  }
}
