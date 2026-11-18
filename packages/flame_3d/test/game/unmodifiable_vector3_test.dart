import 'package:flame_3d/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnmodifiableVector3', () {
    final mutations = <String, void Function(Vector3 v)>{
      'setValues': (v) => v.setValues(1, 2, 3),
      'setFrom': (v) => v.setFrom(Vector3(1, 2, 3)),
      'setZero': (v) => v.setZero(),
      'splat': (v) => v.splat(4),
      '[]=': (v) => v[1] = 5,
      'length=': (v) => v.length = 2,
      'normalize': (v) => v.normalize(),
      'postmultiply': (v) => v.postmultiply(Matrix3.rotationZ(1)),
      'reflect': (v) => v.reflect(Vector3(0, 1, 0)),
      'applyProjection': (v) =>
          v.applyProjection(Matrix4.translationValues(1, 2, 3)),
      'applyAxisAngle': (v) => v.applyAxisAngle(Vector3(0, 0, 1), 1),
      'applyQuaternion': (v) =>
          v.applyQuaternion(Quaternion.axisAngle(Vector3(0, 0, 1), 1)),
      'applyMatrix3': (v) => v.applyMatrix3(Matrix3.rotationZ(1)),
      'applyMatrix4': (v) => v.applyMatrix4(Matrix4.translationValues(1, 2, 3)),
      'add': (v) => v.add(Vector3.all(1)),
      'scale': (v) => v.scale(2),
      'copyFromArray': (v) => v.copyFromArray([7, 8, 9]),
      'x=': (v) => v.x = 9,
      'xz=': (v) => v.xz = Vector2(5, 6),
      'yz=': (v) => v.yz = Vector2(5, 6),
      'zx=': (v) => v.zx = Vector2(5, 6),
      'zy=': (v) => v.zy = Vector2(5, 6),
      'xyz=': (v) => v.xyz = Vector3(5, 6, 7),
      'zyx=': (v) => v.zyx = Vector3(5, 6, 7),
      'rgb=': (v) => v.rgb = Vector3(5, 6, 7),
      'storage[]=': (v) => v.storage[0] = 1,
      'Matrix4.transform3': (v) =>
          Matrix4.translationValues(1, 2, 3).transform3(v),
      'Vector3.crossInto': (v) =>
          Vector3(1, 0, 0).crossInto(Vector3(0, 1, 0), v),
    };

    for (final MapEntry(key: name, value: mutate) in mutations.entries) {
      test('$name throws and leaves the value unchanged', () {
        final vector = UnmodifiableVector3(0.25, 1.5, -2.75);

        expect(() => mutate(vector), throwsUnsupportedError);
        expect(vector, Vector3(0.25, 1.5, -2.75));
      });
    }

    test('constructors hold the given values', () {
      expect(UnmodifiableVector3.zero(), Vector3.zero());
      expect(UnmodifiableVector3.all(2), Vector3.all(2));
      expect(UnmodifiableVector3.copy(Vector3(1, 2, 3)), Vector3(1, 2, 3));
    });

    test('asUnmodifiableView returns an unmodifiable copy', () {
      final source = Vector3(1, 2, 3);
      final view = source.asUnmodifiableView();
      source.x = 10;

      expect(view, Vector3(1, 2, 3));
      expect(() => view.x = 0, throwsUnsupportedError);
    });
  });
}
