import 'package:flame_test/src/close_to_aabb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('closeToAabb', () {
    test('zero aabb', () {
      expect(Aabb2(), closeToAabb(Aabb2()));
      expect(
        Aabb2(),
        closeToAabb(Aabb2.minMax(Vector2.all(1e-5), Vector2.all(1e-4)), 1e-3),
      );
    });

    test('matches normally', () {
      final aabb = Aabb2.minMax(Vector2.zero(), Vector2.all(1));
      expect(aabb, closeToAabb(aabb));
      expect(aabb, closeToAabb(Aabb2(), 2));
      expect(
        aabb,
        closeToAabb(Aabb2.minMax(Vector2.all(1e-16), Vector2.all(1))),
      );
    });

    test('fails on type mismatch', () {
      try {
        expect(3.14, closeToAabb(Aabb2()));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: an Aabb2 object within 1e-15 of '
            'Aabb2([0.0, 0.0]..[0.0, 0.0])',
          ),
        );
        expect(e.message, contains('Actual: <3.14>'));
        expect(e.message, contains('Which: is not an instance of Aabb2'));
      }
    });

    test('fails on value mismatch', () {
      try {
        expect(
          Aabb2.minMax(Vector2.zero(), Vector2.all(1)),
          closeToAabb(Aabb2(), 0.01),
        );
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: an Aabb2 object within 0.01 of '
            'Aabb2([0.0, 0.0]..[0.0, 0.0])',
          ),
        );
        expect(e.message, contains("Actual: <Instance of 'Aabb2'>"));
        expect(e.message, contains('Which: max corner is at distance 1.4142'));
        expect(e.message, contains('Aabb2([0.0, 0.0]..[1.0, 1.0])'));
      }
    });
  });
}
