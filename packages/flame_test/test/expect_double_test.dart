import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('expectDouble', () {
    test('can test double', () {
      const one = 1.0;
      expectDouble(one + 1.0, 2.0);
      expectDouble(one + 1.1, 2.0, epsilon: 0.11);
    });
  });
}
