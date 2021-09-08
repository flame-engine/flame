import 'package:test/test.dart';

import '../../extensions.dart';

// Default is that one pixel away from the expected value is accepted
void expectVector2(
  Vector2 actual,
  Vector2 expected, {
  double epsilon = 1.0,
  String? reason,
}) {
  expect(
    actual.absoluteError(expected),
    closeTo(0.0, epsilon),
    reason: reason,
  );
}
