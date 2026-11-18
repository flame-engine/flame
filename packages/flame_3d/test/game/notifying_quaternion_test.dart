import 'dart:math';

import 'package:flame_3d/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotifyingQuaternion', () {
    final mutations = <String, void Function(Quaternion q)>{
      'setValues': (q) => q.setValues(1, 2, 3, 4),
      'setFrom': (q) => q.setFrom(Quaternion(1, 2, 3, 4)),
      'setAxisAngle': (q) => q.setAxisAngle(Vector3(0, 1, 0), 1),
      'setDQ': (q) => q.setDQ(Quaternion.identity(), Vector3(1, 2, 3)),
      'setEuler': (q) => q.setEuler(1, 2, 3),
      'setFromRotation': (q) => q.setFromRotation(Matrix3.rotationZ(1)),
      'setFromTwoVectors': (q) =>
          q.setFromTwoVectors(Vector3(1, 0, 0), Vector3(0, 1, 0)),
      'setRandom': (q) => q.setRandom(Random(1)),
      '[]=': (q) => q[2] = 5,
      'normalize': (q) => q.normalize(),
      'negate': (q) => q.negate(),
      'conjugate': (q) => q.conjugate(),
      'inverse': (q) => q.inverse(),
      'add': (q) => q.add(Quaternion(1, 1, 1, 1)),
      'sub': (q) => q.sub(Quaternion(1, 1, 1, 1)),
      'scale': (q) => q.scale(2),
      'x=': (q) => q.x = 9,
      'y=': (q) => q.y = 9,
      'z=': (q) => q.z = 9,
      'w=': (q) => q.w = 9,
    };

    for (final MapEntry(key: name, value: mutate) in mutations.entries) {
      test('$name notifies the listeners', () {
        final quaternion = NotifyingQuaternion(0.1, 0.2, 0.3, 0.9);
        var notifications = 0;
        quaternion.addListener(() => notifications++);

        mutate(quaternion);

        expect(notifications, greaterThanOrEqualTo(1));
      });
    }

    test('storage is an unmodifiable view, the same object every time', () {
      final quaternion = NotifyingQuaternion(0, 0, 0, 1);

      expect(identical(quaternion.storage, quaternion.storage), isTrue);
      expect(() => quaternion.storage[0] = 5, throwsUnsupportedError);
    });
  });
}
