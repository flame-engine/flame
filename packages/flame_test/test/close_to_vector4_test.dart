import 'package:flame_test/src/close_to_vector4.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('closeToVector4', () {
    test('matches normally', () {
      expect(Vector4.zero(), closeToVector4(Vector4(0, 0, 0, 0)));
      expect(
        Vector4(-14, 99, -99, 14),
        closeToVector4(Vector4(-14, 99, -99, 14)),
      );
      expect(
        Vector4(1e-20, -1e-16, 0, -0),
        closeToVector4(Vector4(0, 0, 0, 0)),
      );

      expect(
        Vector4(1.0001, 2.0, -1.0001, -0),
        closeToVector4(Vector4(1, 2, -1, 0), 0.01),
      );
      expect(Vector4(5, 9, 11, 15), closeToVector4(Vector4.all(10), 10));
    });

    test('fails on type mismatch - double', () {
      try {
        expect(4.14, closeToVector4(Vector4.zero()));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Vector4 object within 1e-15 of (0.0, 0.0, 0.0, 0.0)',
          ),
        );
        expect(e.message, contains('Actual: <4.14>'));
        expect(e.message, contains('Which: is not an instance of Vector4'));
      }
    });

    test('fails on type mismatch - vector2', () {
      try {
        expect(Vector2(1, 2), closeToVector4(Vector4.zero()));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Vector4 object within 1e-15 of (0.0, 0.0, 0.0, 0.0)',
          ),
        );
        expect(e.message, contains('Actual: Vector2:<[1.0,2.0]>'));
        expect(e.message, contains('Which: is not an instance of Vector4'));
      }
    });

    test('fails on type mismatch - vector3', () {
      try {
        expect(Vector3(1, 2, 3), closeToVector4(Vector4.zero()));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Vector4 object within 1e-15 of (0.0, 0.0, 0.0, 0.0)',
          ),
        );
        expect(e.message, contains('Actual: Vector3:<[1.0,2.0,3.0]>'));
        expect(e.message, contains('Which: is not an instance of Vector4'));
      }
    });

    test('fails on value mismatch', () {
      try {
        expect(
          Vector4(101, 217, 100, 0),
          closeToVector4(Vector4(100, 220, 101, 0)),
        );
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Vector4 object within 1e-15 of '
            '(100.0, 220.0, 101.0, 0.0)',
          ),
        );
        expect(
          e.message,
          contains('Actual: Vector4:<[101.0,217.0,100.0,0.0]>'),
        );
        expect(
          e.message,
          contains('Which: is at distance 3.3166247903554'),
        );
      }
    });
  });
}
