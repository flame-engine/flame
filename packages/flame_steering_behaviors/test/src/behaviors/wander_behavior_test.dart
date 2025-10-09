import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockRandom extends Mock implements Random {}

const _startAngle = 90 * degrees2Radians;
const _randomValue = 0.25;
const _maximumAngle = 90 * degrees2Radians;

void main() {
  final flameTester = FlameTester(TestGame.new);

  group('WanderBehavior', () {
    late Random random;

    setUp(() {
      random = _MockRandom();
      when(random.nextDouble).thenReturn(_randomValue);
    });

    test('fall back to normal Random if none is given', () {
      final behavior = WanderBehavior(
        circleDistance: 1,
        maximumAngle: 2,
        startingAngle: 3,
      );

      expect(behavior.random, isA<Random>());
    });

    flameTester.testGameWidget(
      'calculates the new angle and wandering force',
      setUp: (game, tester) async {
        final behavior = WanderBehavior(
          circleDistance: 40,
          maximumAngle: _maximumAngle,
          startingAngle: _startAngle,
          random: random,
        );

        final parent = SteerableEntity(behaviors: [behavior]);
        await game.ensureAdd(parent);
      },
      verify: (game, tester) async {
        final parent = game.firstChild<SteerableEntity>()!;
        final behavior = parent.findBehavior<WanderBehavior>();

        // The verify does a pump before it calls this so we have a new initial
        // angle.
        const initialAngle =
            _startAngle + _randomValue * _maximumAngle - _maximumAngle * 0.5;
        expect(behavior.angle, initialAngle);

        game.update(1);

        expect(
          behavior.angle,
          initialAngle + _randomValue * _maximumAngle - _maximumAngle * 0.5,
        );
        expect(parent.velocity, closeToVector(Vector2(15.3, 36.95), 0.01));
      },
    );
  });
}
