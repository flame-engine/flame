// Not needed for test files
// ignore_for_file: prefer_const_constructors, cascade_invocations
import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _TestBehavior extends Behavior<SteerableEntity> with Steering {}

class _MockSteeringCore extends Mock implements SteeringCore {}

class _FakeSteerable extends Fake implements Steerable {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final flameTester = FlameTester(TestGame.new);

  group('Steering', () {
    late SteeringCore steeringCore;

    setUp(() {
      registerFallbackValue(_FakeSteerable());

      steeringCore = _MockSteeringCore();
      when(() => steeringCore.getSteering(any())).thenReturn(
        Vector2.all(100),
      );
    });

    flameTester.testGameWidget(
      'update velocity by the linear acceleration from steering',
      setUp: (game, tester) async {
        final behavior = _TestBehavior();
        final entity = SteerableEntity(
          behaviors: [behavior],
          size: Vector2.all(32),
        );
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<SteerableEntity>()!;
        final behavior = entity.findBehavior<_TestBehavior>();

        behavior.steer(steeringCore, 0.25);

        expect(entity.velocity, closeToVector(Vector2(25, 25)));
      },
    );

    flameTester.testGameWidget(
      'clamp velocity to max velocity when the linear acceleration is too high',
      setUp: (game, tester) async {
        final behavior = _TestBehavior();
        final entity = SteerableEntity(
          behaviors: [behavior],
          size: Vector2.all(32),
        );
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<SteerableEntity>()!;
        final behavior = entity.findBehavior<_TestBehavior>();

        behavior.steer(steeringCore, 2);

        expect(entity.velocity, closeToVector(Vector2(70.71, 70.71), 0.01));
      },
    );

    flameTester.testGameWidget(
      'render current velocity as a line in debug mode',
      setUp: (game, tester) async {
        final behavior = _TestBehavior();
        final entity = SteerableEntity(
          position: game.size / 2,
          behaviors: [behavior],
          size: Vector2.all(32),
        )..debugMode = true;

        await game.ensureAdd(entity);

        behavior.steer(steeringCore, 0.25);
      },
      verify: (game, tester) async {
        await tester.pump();

        await expectLater(
          find.byGame<TestGame>(),
          matchesGoldenFile('golden/steering/render_debug_mode.png'),
        );
      },
    );
  });
}
