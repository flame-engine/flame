import 'dart:math';

/// Solves quadratic equation `ax² + bx + c == 0`.
///
/// Depending on the coefficients, either 0 or 2 solutions may be returned. If
/// the equation's determinant is zero, then its 2 roots are equal. In this case
/// we still return them as two solutions.
///
/// If coefficient [a] is equal to zero, then we solve the equation as linear,
/// in which case exactly one solution is returned. If in this case [b] is also
/// zero, then the produced solution will be either Infinity or NaN depending
/// on the value of [c].
List<double> solveQuadratic(double a, double b, double c) {
  if (a == 0) {
    return [-c / b];
  }
  final det = b * b - 4 * a * c;
  if (det >= 0) {
    final sqrtDet = sqrt(det);
    return [(-b - sqrtDet) / (2 * a), (-b + sqrtDet) / (2 * a)];
  } else {
    return [];
  }
}
