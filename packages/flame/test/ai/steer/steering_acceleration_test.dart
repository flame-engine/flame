import 'package:flame/src/ai/steer/steering_acceleration.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('SteeringAcceleration', () {
    test('zero state', () {
      final sa = SteeringAcceleration();
      expect(sa.linearAcceleration, closeToVector(0, 0, epsilon: 0));
      expect(sa.angularAcceleration, 0);
      expect(sa.isZero, true);
    });

    test('non-zero state', () {
      final sa = SteeringAcceleration(linear: Vector2.all(1), angular: 4);
      expect(sa.linearAcceleration, closeToVector(1, 1, epsilon: 0));
      expect(sa.angularAcceleration, 4);
      expect(sa.isZero, false);
      expect(sa.calculateSquareMagnitude(), 18);
    });

    test('setZero()', () {
      final sa = SteeringAcceleration(linear: Vector2.all(1), angular: 4);
      sa.setZero();
      expect(sa.isZero, true);
    });

    test('add()', () {
      final sa1 = SteeringAcceleration(linear: Vector2(1, 1), angular: 3);
      final sa2 = SteeringAcceleration(linear: Vector2(3, -1), angular: -2);
      sa1.add(sa2);
      expect(sa1.linearAcceleration, closeToVector(4, 0, epsilon: 0));
      expect(sa1.angularAcceleration, 1);
      expect(sa2.linearAcceleration, closeToVector(3, -1, epsilon: 0));
      expect(sa2.angularAcceleration, -2);
    });

    test('mulAdd()', () {
      final sa1 = SteeringAcceleration(linear: Vector2(1, 1), angular: 3);
      final sa2 = SteeringAcceleration(linear: Vector2(3, -1), angular: -2);
      sa1.addScaled(sa2, 3);
      expect(sa1.linearAcceleration, closeToVector(10, -2, epsilon: 0));
      expect(sa1.angularAcceleration, -3);
      expect(sa2.linearAcceleration, closeToVector(3, -1, epsilon: 0));
      expect(sa2.angularAcceleration, -2);
    });
  });
}
