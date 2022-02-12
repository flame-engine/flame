import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

@Deprecated('Use closeToVector() instead')
void expectVector2(
  Vector2 actual,
  Vector2 expected, {
  double epsilon = 0.01,
  String? reason,
}) {
  expect(
    actual.absoluteError(expected),
    closeTo(0.0, epsilon),
    reason: reason,
  );
}
