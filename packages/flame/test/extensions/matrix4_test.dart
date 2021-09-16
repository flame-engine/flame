import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Matrix4 test', () {
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

    test('test transform2', () {
      final matrix4 = Matrix4.translation(Vector3(0, 10, 0));
      final input = Vector2.all(10);

      expectVector2(matrix4.transform2(input), Vector2(10, 20));
    });

    test('test transformed2', () {
      final matrix4 = Matrix4.translation(Vector3(0, 10, 0));
      final input = Vector2.all(10);
      final out = Vector2.zero();
      final result = matrix4.transformed2(input, out);

      expectVector2(out, input);
      expectVector2(result, Vector2(10, 20));
    });
  });
}
