import 'package:flame/extensions.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Flee', () {
    test('calculates the fleeing acceleration', () {
      final parent = SteerableEntity(position: Vector2.all(50));
      final target = SteerableEntity(position: Vector2.zero());

      final flee = Flee(
        target,
        maxAcceleration: 100,
      );

      final steering = flee.getSteering(parent);

      expect(steering, closeToVector(Vector2(70.71, 70.71), 0.01));
    });

    test(
      'the fleeing acceleration length is clamped to max acceleration',
      () {
        final parent = SteerableEntity(position: Vector2.all(50));
        final target = SteerableEntity(position: Vector2.zero());

        final flee = Flee(
          target,
          maxAcceleration: 50,
        );

        final steering = flee.getSteering(parent);

        expect(steering.length, closeTo(50, 0.01));
        expect(steering, closeToVector(Vector2(35.35, 35.35), 0.01));
      },
    );
  });
}
