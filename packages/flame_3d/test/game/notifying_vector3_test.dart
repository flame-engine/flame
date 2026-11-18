import 'package:flame_3d/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotifyingVector3', () {
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
      'addScaled': (v) => v.addScaled(Vector3.all(1), 2),
      'sub': (v) => v.sub(Vector3.all(1)),
      'multiply': (v) => v.multiply(Vector3.all(2)),
      'divide': (v) => v.divide(Vector3.all(2)),
      'scale': (v) => v.scale(2),
      'negate': (v) => v.negate(),
      'absolute': (v) => v.absolute(),
      'clamp': (v) => v.clamp(Vector3.zero(), Vector3.all(0.5)),
      'clampScalar': (v) => v.clampScalar(0, 0.5),
      'floor': (v) => v.floor(),
      'ceil': (v) => v.ceil(),
      'round': (v) => v.round(),
      'roundToZero': (v) => v.roundToZero(),
      'copyFromArray': (v) => v.copyFromArray([7, 8, 9]),
      'x=': (v) => v.x = 9,
      'y=': (v) => v.y = 9,
      'z=': (v) => v.z = 9,
      'r=': (v) => v.r = 9,
      'xy=': (v) => v.xy = Vector2(5, 6),
      'xz=': (v) => v.xz = Vector2(5, 6),
      'yx=': (v) => v.yx = Vector2(5, 6),
      'yz=': (v) => v.yz = Vector2(5, 6),
      'zx=': (v) => v.zx = Vector2(5, 6),
      'zy=': (v) => v.zy = Vector2(5, 6),
      'rb=': (v) => v.rb = Vector2(5, 6),
      'xyz=': (v) => v.xyz = Vector3(5, 6, 7),
      'xzy=': (v) => v.xzy = Vector3(5, 6, 7),
      'yxz=': (v) => v.yxz = Vector3(5, 6, 7),
      'yzx=': (v) => v.yzx = Vector3(5, 6, 7),
      'zxy=': (v) => v.zxy = Vector3(5, 6, 7),
      'zyx=': (v) => v.zyx = Vector3(5, 6, 7),
      'bgr=': (v) => v.bgr = Vector3(5, 6, 7),
    };

    for (final MapEntry(key: name, value: mutate) in mutations.entries) {
      test('$name notifies the listeners', () {
        final vector = NotifyingVector3(0.25, 1.5, -2.75);
        var notifications = 0;
        vector.addListener(() => notifications++);

        mutate(vector);

        expect(notifications, greaterThanOrEqualTo(1));
      });
    }

    test('swizzle setters write the expected components', () {
      final vector = NotifyingVector3.zero()..zx = Vector2(1, 2);
      expect(vector, Vector3(2, 0, 1));
      vector.yzx = Vector3(3, 4, 5);
      expect(vector, Vector3(5, 3, 4));
    });

    test('storage is an unmodifiable view, the same object every time', () {
      final vector = NotifyingVector3(1, 2, 3);

      expect(identical(vector.storage, vector.storage), isTrue);
      expect(() => vector.storage[0] = 5, throwsUnsupportedError);
      vector.x = 5;
      expect(vector.storage[0], 5);
    });
  });
}
