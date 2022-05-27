import 'dart:math';

/// Solves quadratic equation `ax² + bx + c == 0`.
///
/// Depending on the coefficients, either 0, 1, or 2 solutions may be returned.
/// If coefficient [a] is very close to zero, then we assume it is equal to
/// zero, and solve the equation as a linear one.
List<double> solveQuadratic(double a, double b, double c) {
  if (a.abs() < equationEpsilon) {
    return [-c / b];
  }
  final det = b * b - 4 * a * c;
  if (det > 0) {
    final sqrtDet = sqrt(det);
    return [(-b - sqrtDet) / (2 * a), (-b + sqrtDet) / (2 * a)];
  } else if (det == 0) {
    return [-b / (2 * a)];
  } else {
    return [];
  }
}

double equationEpsilon = 1e-300;
