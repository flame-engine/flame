import 'package:test/test.dart';

void expectDouble(
  double d1,
  double d2, {
  double epsilon = 0.01,
  String? reason,
}) {
  expect(d1, closeTo(d2, epsilon), reason: reason);
}
