import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flame_steering_behaviors_example/src/entities/entities.dart';
import 'package:flame_steering_behaviors_example/src/example_game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockRandom extends Mock implements Random {}

void main() {
  final flameTester = FlameTester(TestGame.new);

  group('Dot', () {
    late Random random;

    setUp(() {
      random = _MockRandom();
      when(() => random.nextDouble()).thenReturn(0);
    });

    flameTester.testGameWidget(
      'loads correctly',
      setUp: (game, tester) async {
        final dot = Dot(position: Vector2.zero(), random: random);
        await game.ensureAdd(dot);

        expect(dot.hasBehavior<WanderBehavior>(), isTrue);
        expect(dot.hasBehavior<SeparationBehavior>(), isTrue);
      },
    );

    test('has correct max velocity', () {
      final dot = Dot(position: Vector2.zero(), random: random);
      expect(dot.maxVelocity, equals(10 * relativeValue));
    });
  });
}
