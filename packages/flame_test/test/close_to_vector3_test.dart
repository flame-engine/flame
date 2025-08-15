import 'package:flame_test/src/close_to_vector3.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('closeToVector3', () {
    test('matches normally', () {
      expect(Vector3.zero(), closeToVector3(Vector3(0, 0, 0)));
      expect(Vector3(-14, 99, -99), closeToVector3(Vector3(-14, 99, -99)));
      expect(Vector3(1e-20, -1e-16, 0), closeToVector3(Vector3(0, 0, 0)));

      expect(
        Vector3(1.0001, 2.0, -1.0001),
        closeToVector3(Vector3(1, 2, -1), 0.01),
      );
      expect(Vector3(9, 10, 11), closeToVector3(Vector3.all(10), 10));
    });

    test('fails on type mismatch - double', () {
      try {
        expect(3.14, closeToVector3(Vector3.zero()));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Vector3 object within 1e-15 of (0.0, 0.0, 0.0)',
          ),
        );
        expect(e.message, contains('Actual: <3.14>'));
        expect(e.message, contains('Which: is not an instance of Vector3'));
      }
    });

    test('fails on type mismatch - vector2', () {
      try {
        expect(Vector2(1, 2), closeToVector3(Vector3.zero()));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Vector3 object within 1e-15 of (0.0, 0.0, 0.0)',
          ),
        );
        expect(e.message, contains('Actual: Vector2:<[1.0,2.0]>'));
        expect(e.message, contains('Which: is not an instance of Vector3'));
      }
    });

    test('fails on type mismatch - vector4', () {
      try {
        expect(Vector4(1, 2, 3, 4), closeToVector3(Vector3.zero()));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Vector3 object within 1e-15 of (0.0, 0.0, 0.0)',
          ),
        );
        expect(e.message, contains('Actual: Vector4:<[1.0,2.0,3.0,4.0]>'));
        expect(e.message, contains('Which: is not an instance of Vector3'));
      }
    });

    test('fails on value mismatch', () {
      try {
        expect(Vector3(101, 217, 100), closeToVector3(Vector3(100, 220, 101)));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Vector3 object within 1e-15 of (100.0, 220.0, 101.0)',
          ),
        );
        expect(e.message, contains('Actual: Vector3:<[101.0,217.0,100.0]>'));
        expect(e.message, contains('Which: is at distance 3.3166247903554'));
      }
    });
  });
}
