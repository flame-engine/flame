import 'dart:math';

import 'package:flame/src/utils/solve_quadratic.dart';

/// Solves cubic equation `ax³ + bx² + cx + d == 0`.
///
/// Depending on the coefficients, either 0, 1, 2, or 3 solutions may be
/// produced.
/// If coefficient [a] is very close to zero, then we assume it is equal to
/// zero, and solve the equation as a quadratic one.
List<double> solveCubic(double a, double b, double c, double d) {
  if (a.abs() < coefficientEpsilon) {
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
    if (p.abs() < coefficientEpsilon) {
      return [0];
    } else {
      final x1 = 3 * q / p;
      final x2 = -x1 / 2;
      return [x1, x2];
    }
  } else if (discriminant > 0) {
    final c = pow(-q / 2 + sqrt(discriminant), 1 / 3);
    return [c - p / (3 * c)];
  } else {
    final f = 2 * sqrt(-p / 3);
    final v = acos(3 * q / (f * p)) / 3;
    final x0 = f * cos(v);
    final x1 = f * cos(v - 1 / 3 * tau);
    final x2 = f * cos(v - 2 / 3 * tau);
    return [x0, x1, x2];
  }
}

const discriminantEpsilon = 1e-13;
const coefficientEpsilon = 1e-15;
const tau = 2 * pi;
