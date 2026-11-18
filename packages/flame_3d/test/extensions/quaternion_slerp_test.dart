import 'package:flame_3d/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuaternionUtils.slerp', () {
    test('takes the short path between nearly opposite quaternions', () {
      final q = Quaternion.axisAngle(Vector3(0, 1, 0), 0.5);
      // Same rotation (up to a tiny change), opposite sign.
      final nearlyMinusQ = Quaternion.axisAngle(Vector3(0, 1, 0), 0.5 + 1e-7)
        ..scale(-1);

      final result = QuaternionUtils.slerp(q, nearlyMinusQ, 0.5);

      expect(result.length, closeTo(1, 1e-6));
      // The result is the same rotation as q (up to sign).
      expect(result.dot(q).abs(), closeTo(1, 1e-6));
    });

    test('returns a copy when both quaternions are equal', () {
      final q = Quaternion.axisAngle(Vector3(0, 1, 0), 0.5);

      final result = QuaternionUtils.slerp(q, q.clone(), 0.5);
      result.setValues(0, 0, 0, 1);

      expect(q, Quaternion.axisAngle(Vector3(0, 1, 0), 0.5));
    });
  });
}
