import 'package:test/test.dart';

import '../../extensions.dart';

void expectVector2(
  Vector2 actual,
  Vector2 expected, {
  double epsilon = 0.4,
  String? reason,
}) {
  expect(
    actual.absoluteError(expected),
    closeTo(0.0, epsilon),
    reason: reason,
  );
}
