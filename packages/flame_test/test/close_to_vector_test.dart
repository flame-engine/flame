import 'package:flame_test/src/close_to_vector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('closeToVector', () {
    test('matches normally', () {
      expect(Vector2.zero(), closeToVector(0, 0));
      expect(Vector2(-14, 99), closeToVector(-14, 99));
      expect(Vector2(1e-20, -1e-16), closeToVector(0, 0));

      expect(Vector2(1.0001, 2.0), closeToVector(1, 2, epsilon: 0.01));
      expect(Vector2(13, 14), closeToVector(10, 10, epsilon: 5));
    });

    test('fails on type mismatch', () {
      try {
        expect(3.14, closeToVector(0, 0));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains('Expected: a Vector2 object within 1e-15 of (0.0, 0.0)'),
        );
        expect(e.message, contains('Actual: <3.14>'));
        expect(e.message, contains('Which: is not an instance of Vector2'));
      }
    });

    test('fails on value mismatch', () {
      try {
        expect(Vector2(101, 217), closeToVector(100, 220));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains('Expected: a Vector2 object within 1e-15 of (100.0, 220.0)'),
        );
        expect(e.message, contains('Actual: Vector2:<[101.0,217.0]>'));
        expect(e.message, contains('Which: is at distance 3.16227766'));
      }
    });
  });
}
