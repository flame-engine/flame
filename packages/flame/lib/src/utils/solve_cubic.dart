import 'dart:math';

import 'package:flame/src/utils/solve_quadratic.dart';

/// Solves cubic equation `ax³ + bx² + cx + d == 0`.
///
/// Depending on the coefficients, either 1 or 3 real solutions may be returned.
/// In degenerate cases, when some of the roots of the equation coincide, we
/// return all such roots without deduplication.
///
/// If coefficient [a] is equal to zero, then we solve the equation as a
/// quadratic one (see [solveQuadratic]).
List<double> solveCubic(double a, double b, double c, double d) {
  if (a == 0) {
    return solveQuadratic(b, c, d);
  }
  if (b == 0) {
    return _solveDepressedCubic(c / a, d / a);
  } else {
    final s = b / (3 * a);
    final p = c / a - 3 * s * s;
    final q = d / a - (p + s * s) * s;
    return _solveDepressedCubic(p, q).map((t) => t - s).toList();
  }
}

/// Solves cubic equation `x³ + px + q == 0`.
List<double> _solveDepressedCubic(double p, double q) {
  final discriminant = q * q / 4 + p * p * p / 27;
  // If the discriminant is very close to zero, then we will treat this as if
  // it was equal to zero.
  if (discriminant.abs() < discriminantEpsilon) {
    final x1 = _cubicRoot(q / 2);
    final x2 = -2 * x1;
    return [x1, x1, x2];
  } else if (discriminant > 0) {
    final w = _cubicRoot(q.abs() / 2 + sqrt(discriminant));
    return [(p / (3 * w) - w) * q.sign];
  } else {
    final f = 2 * sqrt(-p / 3);
    final v = acos(3 * q / (f * p)) / 3;
    final x0 = f * cos(v);
    final x1 = f * cos(v - 1 / 3 * tau);
    final x2 = f * cos(v - 2 / 3 * tau);
    return [x0, x1, x2];
  }
}

double _cubicRoot(double x) {
  // Note: `pow(x, y)` function cannot handle negative values of `x`
  if (x >= 0) {
    return pow(x, 1 / 3).toDouble();
  } else {
    return -pow(-x, 1 / 3).toDouble();
  }
}

const discriminantEpsilon = 1e-15;
const tau = 2 * pi;
