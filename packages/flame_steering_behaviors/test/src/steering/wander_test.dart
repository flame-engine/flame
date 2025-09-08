import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockRandom extends Mock implements Random {}

void main() {
  group('Wander', () {
    late Random random;

    setUp(() {
      random = _MockRandom();
      when(random.nextDouble).thenReturn(0);
    });

    test('calculates new orientation', () {
      const startAngle = 90 * degrees2Radians;
      const randomValue = 0.25;
      const maximumAngle = 90 * degrees2Radians;

      const expectedAngle =
          startAngle + (randomValue * maximumAngle) - (maximumAngle * 0.5);

      final parent = SteerableEntity(position: Vector2.zero());
      final steering = Wander(
        circleDistance: 40,
        maximumAngle: maximumAngle,
        angle: startAngle,
        onNewAngle: (angle) {
          expect(angle, equals(expectedAngle));
        },
        random: random,
      );

      when(random.nextDouble).thenReturn(0.25);

      steering.getSteering(parent);
    });

    group('calculates the wandering force', () {
      test('when the start angle is 0 it should go to the right', () {
        final parent = SteerableEntity(position: Vector2.zero());

        final steering = Wander(
          circleDistance: 40,
          angle: 0,
          maximumAngle: 0,
          onNewAngle: (angle) {},
          random: random,
        );

        final linearAcceleration = steering.getSteering(parent);
        expect(linearAcceleration, closeToVector(Vector2(40, 0), 0.01));
      });

      test('when the start angle is 180 it should go to the left', () {
        final parent = SteerableEntity(position: Vector2.zero());

        final steering = Wander(
          circleDistance: 40,
          angle: 180 * degrees2Radians,
          maximumAngle: 0,
          onNewAngle: (angle) {},
          random: random,
        );

        when(random.nextDouble).thenReturn(0.25);

        final linearAcceleration = steering.getSteering(parent);
        expect(linearAcceleration, closeToVector(Vector2(-40, 0), 0.01));
      });

      test('when the start angle is 90 it should go to the bottom', () {
        final parent = SteerableEntity(position: Vector2.zero());

        final steering = Wander(
          circleDistance: 40,
          maximumAngle: 0,
          angle: 90 * degrees2Radians,
          onNewAngle: (angle) {},
          random: random,
        );

        when(random.nextDouble).thenReturn(0.25);

        final linearAcceleration = steering.getSteering(parent);
        expect(linearAcceleration, closeToVector(Vector2(0, 40), 0.01));
      });

      test('when the start angle is 270 it should go to the top', () {
        final parent = SteerableEntity(position: Vector2.zero());

        final steering = Wander(
          circleDistance: 40,
          angle: 270 * degrees2Radians,
          maximumAngle: 0,
          onNewAngle: (angle) {},
          random: random,
        );

        final linearAcceleration = steering.getSteering(parent);
        expect(linearAcceleration, closeToVector(Vector2(0, -40), 0.01));
      });
    });
  });
}
