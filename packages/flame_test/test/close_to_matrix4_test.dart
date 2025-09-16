import 'package:flame_test/src/close_to_matrix4.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('closeToMatrix4', () {
    test('matches normally', () {
      expect(
        Matrix4.zero(),
        closeToMatrix4(
          Matrix4.columns(
            Vector4.zero(),
            Vector4.zero(),
            Vector4.zero(),
            Vector4.zero(),
          ),
        ),
      );
      expect(
        Matrix4(
          -14,
          99,
          -99,
          0, //
          0,
          0,
          0,
          0, //
          1e-20,
          -1e-16,
          0,
          0, //
          0,
          0,
          0,
          0, //
        ),
        closeToMatrix4(
          Matrix4.columns(
            Vector4(-14, 99, -99, 0),
            Vector4(0, 0, 0, 0),
            Vector4(0, 0, 0, 0),
            Vector4(0, 0, 0, 0),
          ),
        ),
      );

      expect(
        Matrix4.columns(
          Vector4(1.0001, 2.0, -1.0001, 1.99999),
          Vector4(0, 0, 0, 0),
          Vector4(0, 0, 0, 0),
          Vector4(0, 0, 0, 0),
        ),
        closeToMatrix4(
          Matrix4.columns(
            Vector4(1, 2, -1, 2),
            Vector4(0, 0, 0, 0),
            Vector4(0, 0, 0, 0),
            Vector4(0, 0, 0, 0),
          ),
          0.01,
        ),
      );
    });

    test('fails on type mismatch', () {
      try {
        expect(3.14, closeToMatrix4(Matrix4.zero()));
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Matrix4 object within 1e-15 of '
            '(0.0, 0.0, 0.0, 0.0, '
            '0.0, 0.0, 0.0, 0.0, '
            '0.0, 0.0, 0.0, 0.0, '
            '0.0, 0.0, 0.0, 0.0)',
          ),
        );
        expect(e.message, contains('Actual: <3.14>'));
        expect(e.message, contains('Which: is not an instance of Matrix4'));
      }
    });

    test('fails on value mismatch', () {
      try {
        expect(
          Matrix4.columns(
            Vector4(101, 217, 100, 0),
            Vector4(0, 0, 0, 0),
            Vector4(0, 0, 0, 0),
            Vector4(0, 0, 0, 0),
          ),
          closeToMatrix4(
            Matrix4.columns(
              Vector4(100, 220, 101, 0),
              Vector4(0, 0, 0, 0),
              Vector4(0, 0, 0, 0),
              Vector4(0, 0, 0, 0),
            ),
          ),
        );
      } on TestFailure catch (e) {
        expect(
          e.message,
          contains(
            'Expected: a Matrix4 object within 1e-15 of '
            '(100.0, 220.0, 101.0, 0.0, '
            '0.0, 0.0, 0.0, 0.0, '
            '0.0, 0.0, 0.0, 0.0, '
            '0.0, 0.0, 0.0, 0.0)',
          ),
        );
        expect(
          e.message,
          contains('Actual: Matrix4:<[0] [101.0,0.0,0.0,0.0]\n'),
        );
        expect(e.message, contains('[1] [217.0,0.0,0.0,0.0]\n'));
        expect(e.message, contains('[2] [100.0,0.0,0.0,0.0]\n'));
        expect(e.message, contains('[3] [0.0,0.0,0.0,0.0]\n'));
        expect(
          e.message,
          contains(
            '>\n',
          ),
        );
        expect(
          e.message,
          contains(
            'Which: is not within 1e-15 of (100.0, 220.0, 101.0, 0.0, '
            '0.0, 0.0, 0.0, 0.0, '
            '0.0, 0.0, 0.0, 0.0, '
            '0.0, 0.0, 0.0, 0.0)',
          ),
        );
      }
    });
  });
}
