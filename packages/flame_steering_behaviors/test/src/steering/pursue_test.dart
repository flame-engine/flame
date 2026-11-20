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
      final target = SteerableEntity(position: Vector2.zero());

      final pursue = Pursue(
        target,
        maxPrediction: 2,
      );

      final steering = pursue.getSteering(parent);

      expect(steering, closeToVector(Vector2(0, 0)));
    });

    test('offsets the target by the predicted displacement only', () {
      final parent = SteerableEntity(position: Vector2(10, 0))
        ..velocity.setValues(0, 10);
      final target = SteerableEntity(position: Vector2(10, 30));

      final pursue = Pursue(
        target,
        maxPrediction: 5,
      );

      // distance = 30, speed = 10, so prediction = distance / speed = 3.
      // The predicted target is (10, 30) + (0, 10) * 3 = (10, 60), which is
      // directly above the parent, so the steering should point straight up.
      final steering = pursue.getSteering(parent);

      expect(steering, closeToVector(Vector2(0, 100), 0.01));
    });
  });
}
