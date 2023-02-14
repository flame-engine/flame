import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '_help.dart';

void main() {
  group('Matrix4Extension', () {
    final matrix4 = Matrix4.fromList([
      1, 2, 3, 4, // first row
      5, 6, 7, 8, // second row
      9, 10, 11, 12, // third row
      13, 14, 15, 16, // fourth row
    ]);

    test('test m11', () => expect(matrix4.m11, matrix4.storage[0]));
    test('test m12', () => expect(matrix4.m12, matrix4.storage[1]));
    test('test m13', () => expect(matrix4.m13, matrix4.storage[2]));
    test('test m14', () => expect(matrix4.m14, matrix4.storage[3]));
    test('test m21', () => expect(matrix4.m21, matrix4.storage[4]));
    test('test m22', () => expect(matrix4.m22, matrix4.storage[5]));
    test('test m23', () => expect(matrix4.m23, matrix4.storage[6]));
    test('test m24', () => expect(matrix4.m24, matrix4.storage[7]));
    test('test m31', () => expect(matrix4.m31, matrix4.storage[8]));
    test('test m32', () => expect(matrix4.m32, matrix4.storage[9]));
    test('test m33', () => expect(matrix4.m33, matrix4.storage[10]));
    test('test m34', () => expect(matrix4.m34, matrix4.storage[11]));
    test('test m41', () => expect(matrix4.m41, matrix4.storage[12]));
    test('test m42', () => expect(matrix4.m42, matrix4.storage[13]));
    test('test m43', () => expect(matrix4.m43, matrix4.storage[14]));
    test('test m44', () => expect(matrix4.m44, matrix4.storage[15]));

    testRandom('translate2 calls translate on the matrix with a vector',
        (Random r) {
      final matrix4 = MockMatrix4();
      final v = Vector2(r.nextDouble(), r.nextDouble());
      matrix4.translate2(v);
      verify(() => matrix4.translate(v.x, v.y)).called(1);
    });

    group('transformed2', () {
      test('Without out', () {
        final matrix4 = Matrix4.translation(Vector3(0, 10, 0));
        final input = Vector2.all(10);
        expect(matrix4.transform2(input), closeToVector(Vector2(10, 20)));
      });

      test('With correct out', () {
        final matrix4 = Matrix4.translation(Vector3(0, 10, 0));
        final input = Vector2.all(10);
        final out = Vector2.zero();
        final result = matrix4.transformed2(input, out);

        expect(out, closeToVector(input));
        expect(result, closeToVector(Vector2(10, 20)));
      });

      test('With explicit null out', () {
        final matrix4 = Matrix4.translation(Vector3(0, 10, 0));
        final input = Vector2.all(10);
        // ignore: avoid_redundant_argument_values
        final result = matrix4.transformed2(input, null);

        expect(Vector2.copy(input), closeToVector(input));
        expect(result, closeToVector(Vector2(10, 20)));
      });
    });

    testRandom('scale returns identity scaled', (Random r) {
      final x = r.nextDouble();
      final y = r.nextDouble();
      final z = r.nextDouble();

      final xScaledMatrix = Matrix4Extension.scale(x);
      final xScaledIdentity = Matrix4.fromList([
        x, 0, 0, 0, // first row
        0, x, 0, 0, // second row
        0, 0, x, 0, // third row
        0, 0, 0, 1, // fourth row
      ]);
      expect(xScaledMatrix, xScaledIdentity);

      final xyScaledMatrix = Matrix4Extension.scale(x, y);
      final xyScaledIdentity = Matrix4.fromList([
        x, 0, 0, 0, // first row
        0, y, 0, 0, // second row
        0, 0, x, 0, // third row
        0, 0, 0, 1, // fourth row
      ]);
      expect(xyScaledMatrix, xyScaledIdentity);

      final xyzScaledMatrix = Matrix4Extension.scale(x, y, z);
      final xyzScaledIdentity = Matrix4.fromList([
        x, 0, 0, 0, // first row
        0, y, 0, 0, // second row
        0, 0, z, 0, // third row
        0, 0, 0, 1, // fourth row
      ]);
      expect(xyzScaledMatrix, xyzScaledIdentity);
    });
  });
}

// This need the mixin because Mock's == paramter is not nullable
// but Matrix4's == paramter is nullable
class MockMatrix4 extends Mock with NullableEqualsMixin implements Matrix4 {}
