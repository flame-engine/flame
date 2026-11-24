import 'package:flame/extensions.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Pursue', () {
    test('calculates the pursue-ing acceleration', () {
      final parent = SteerableEntity(position: Vector2.all(50));
      final target = SteerableEntity(position: Vector2.zero());

      final pursue = Pursue(
        target,
        maxPrediction: 0.1,
      );

      final steering = pursue.getSteering(parent);

      expect(steering, closeToVector(Vector2(-70.71, -70.71), 0.01));
    });

    test('clamps prediction by max prediction based on speed and distance', () {
      final parent = SteerableEntity(position: Vector2.all(19))
        ..velocity.setValues(10, 10);
      final target = SteerableEntity(position: Vector2.zero())
        ..velocity.setValues(10, 10);

      final pursue = Pursue(
        target,
        maxPrediction: 2,
      );

      // The parent is fast enough that the prediction is clamped to
      // distance / speed = 1.9. The predicted target position is
      // (0, 0) + (10, 10) * 1.9 = (19, 19), which is exactly where the parent
      // already is, so the steering is zero.
      final steering = pursue.getSteering(parent);

      expect(steering, closeToVector(Vector2(0, 0)));
    });

    test('leads a moving target along the target velocity', () {
      final parent = SteerableEntity(position: Vector2.zero());
      final target = SteerableEntity(position: Vector2(0, 30))
        ..velocity.setValues(10, 0);

      final pursue = Pursue(
        target,
        maxPrediction: 5,
      );

      // The parent is at rest, so the prediction is clamped to
      // maxPrediction (5). The target moves along +x, so its predicted
      // position is (0, 30) + (10, 0) * 5 = (50, 30). The steering therefore
      // leads the target toward +x instead of pointing straight at its
      // current position of (0, 30).
      final steering = pursue.getSteering(parent);

      expect(steering, closeToVector(Vector2(85.75, 51.45), 0.01));
    });
  });
}
