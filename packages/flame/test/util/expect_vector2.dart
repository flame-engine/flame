import 'package:flame/extensions.dart';
import 'package:test/test.dart';

// TODO(luan) refactor other tests to use this
void expectVector2(
  Vector2 actual,
  Vector2 expected, {
  double epsilon = 0.01,
}) {
  expect(
    actual.absoluteError(expected),
    closeTo(0.0, epsilon),
  );
}
