import 'package:flame_3d/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Quaternion extensions', () {
    test('can lerp', () {
      final a = Quaternion(1, 2, 3, 4);
      final b = Quaternion(3, 4, 5, 6);

      final result = a.lerp(b, 0.5);
      expect(result.x, 2);
      expect(result.y, 3);
      expect(result.z, 4);
      expect(result.w, 5);
    });

    test('can slerp', () {
      const angle1 = 1.2;
      const angle2 = 0.7;
      const angle3 = angle2 + _epsilon * 10;

      final axis = Vector3(1, 0, 0);

      final quaternion1 = Quaternion.axisAngle(axis, angle1);
      final quaternion2 = Quaternion.axisAngle(axis, angle2);
      final quaternion3 = Quaternion.axisAngle(axis, angle3);

      final slerp1 = QuaternionUtils.slerp(quaternion1, quaternion2, 0.5);
      expect(
        angle1 - 0.5 * (angle1 - angle2),
        closeTo(slerp1.radians, _epsilon),
      );

      final slerp2 = QuaternionUtils.slerp(quaternion2, quaternion3, 0.75);
      expect(
        angle2 + 0.75 * (angle3 - angle2),
        closeTo(slerp2.radians, _epsilon),
      );

      final slerp3 = QuaternionUtils.slerp(quaternion2, quaternion2, 0.5);
      expect(angle2, closeTo(slerp3.radians, _epsilon));
    });
  });
}

const _epsilon = 10e-6;
