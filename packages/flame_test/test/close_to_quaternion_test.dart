import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('closeToQuaternion', () {
    test('matches normally', () {
      expect(
        Quaternion.fromRotation(Matrix3.identity()),
        closeToQuaternion(Quaternion(0, 0, 0, 1)),
      );
      expect(
        Quaternion(-14, 99, -99, 14),
        closeToQuaternion(Quaternion(-14, 99, -99, 14)),
      );
      expect(
        Quaternion(1e-20, -1e-16, 0, -0),
        closeToQuaternion(Quaternion(0, 0, 0, 0)),
      );

      expect(
        Quaternion(1.0001, 2.0, -1.0001, -0),
        closeToQuaternion(Quaternion(1, 2, -1, 0), 0.01),
      );
      expect(
        Quaternion(5, 9, 11, 15),
        closeToQuaternion(Quaternion(10, 10, 10, 10), 10),
      );
    });

    test('fails on type mismatch', () {
      try {
        expect(4.14, closeToQuaternion(Quaternion(0, 0, 0, 0)));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Quaternion object within 1e-15 of '
            '(0.0, 0.0, 0.0, 0.0)',
          ),
        );
        expect(e.message, contains('Actual: <4.14>'));
        expect(e.message, contains('Which: is not an instance of Quaternion'));
      }
    });

    test('fails on value mismatch', () {
      try {
        expect(
          Quaternion(101, 217, 100, 0),
          closeToQuaternion(Quaternion(100, 220, 101, 0)),
        );
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Quaternion object within 1e-15 of '
            '(100.0, 220.0, 101.0, 0.0)',
          ),
        );
        expect(
          e.message,
          contains('Actual: Quaternion:<101.0, 217.0, 100.0 @ 0.0>'),
        );
        expect(e.message, contains('Which: is at distance 3.3166247903554'));
      }
    });
  });
}
