import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/steer.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('Pursue', () {
    group('fast pursuit', () {
      /// Given the target that starts at [targetPosition] and then moves at a
      /// constant [targetVelocity], and the pursuer that starts at the origin
      /// and has [agentInitialVelocity] -- calculate the time it would take the
      /// pursuer to capture the target, provided that the pursuer can move at
      /// [maxSpeed] and achieve [maxAcceleration]. The max speed of the pursuer
      /// must exceed the max speed of the target.
      ///
      /// The return value is the amount of time it took for the pursuer to
      /// reach its target, assuming the capture happens when the distance
      /// between the pursuer and the target is less than [captureDistance].
      Future<double> simulateFastPursuit({
        required Vector2 targetPosition,
        required Vector2 targetVelocity,
        required Vector2 agentInitialVelocity,
        required double maxSpeed,
        required double maxAcceleration,
        double captureDistance = 10.0,
        double dt = 0.02,
        double timeout = 1000,
      }) async {
        assert(
          maxSpeed > targetVelocity.length,
          'Max speed of the agent must be greater than the speed of the target',
        );
        final target = SteerableComponent(
          position: targetPosition,
          velocity: targetVelocity,
        );
        final agent = SteerableComponent(velocity: agentInitialVelocity)
          ..maxLinearSpeed = maxSpeed
          ..maxLinearAcceleration = maxAcceleration
          ..behavior = Pursue(target: target);

        final game = FlameGame()..onGameResize(Vector2.all(1000));
        await game.ensureAdd(target);
        await game.ensureAdd(agent);
        game.update(0);

        var totalTime = 0.0;
        while ((target.position - agent.position).length > captureDistance &&
            totalTime < timeout) {
          game.update(dt);
          totalTime += dt;
        }
        return totalTime;
      }

      test('pursuit exact', () async {
        final t = await simulateFastPursuit(
          targetPosition: Vector2(100, 0),
          targetVelocity: Vector2(20, 0),
          agentInitialVelocity: Vector2.zero(),
          maxSpeed: 50,
          maxAcceleration: 10,
          captureDistance: 15,
        );
        // At acceleration 10, the agent will gain max speed in 5 seconds; since
        // it needs to be within distance 15 from the target, the capture must
        // occur in 7 seconds:
        //   100 + 20t == 50(t - 5) + 1/2*10*5^2 + 15  => t = 7
        expect(t, closeTo(7, 0.02));
      });

      // All other tests simply try various configurations, and then assert that
      // the capture time should be close to what was observed at previous runs
      // of the same test. Future improvements to the pursuit algorithm may
      // bring these times down. If they go up, then it wasn't an improvement.

      test('pursuit 1', () async {
        final t = await simulateFastPursuit(
          targetPosition: Vector2(100, 30),
          targetVelocity: Vector2(10, 10),
          agentInitialVelocity: Vector2.zero(),
          maxSpeed: 50,
          maxAcceleration: 20,
        );
        expect(t, closeTo(4.28, 0.05));
      });

      test('pursuit 2', () async {
        final t = await simulateFastPursuit(
          targetPosition: Vector2(100, 30),
          targetVelocity: Vector2(10, 10),
          agentInitialVelocity: Vector2.zero(),
          maxSpeed: 50,
          maxAcceleration: 20,
        );
        expect(t, closeTo(4.28, 0.05));
      });

      test('pursuit 3', () async {
        final t = await simulateFastPursuit(
          targetPosition: Vector2(50, 0),
          targetVelocity: Vector2(0, 20),
          agentInitialVelocity: Vector2.zero(),
          maxSpeed: 50,
          maxAcceleration: 20,
        );
        expect(t, closeTo(2.6, 0.05));
      });

      test('pursuit 4', () async {
        final t = await simulateFastPursuit(
          targetPosition: Vector2(30, 0),
          targetVelocity: Vector2(0, 20),
          agentInitialVelocity: Vector2(40, -10),
          maxSpeed: 50,
          maxAcceleration: 20,
        );
        expect(t, closeTo(4.8, 0.1));
      });

      test('pursuit 5', () async {
        final t = await simulateFastPursuit(
          targetPosition: Vector2(40, 0),
          targetVelocity: Vector2(-20, -10),
          agentInitialVelocity: Vector2(10, 30),
          maxSpeed: 50,
          maxAcceleration: 10,
        );
        expect(t, closeTo(10.84, 0.02));
      });

      test('pursuit 6', () async {
        final t = await simulateFastPursuit(
          targetPosition: Vector2(40, 0),
          targetVelocity: Vector2(20, -10),
          agentInitialVelocity: Vector2(-20, 30),
          maxSpeed: 50,
          maxAcceleration: 1000,
        );
        expect(t, closeTo(1.18, 0.02));
      });
    });

    group('slow pursuit', () {
      /// Similar to `simulateFastPursuit`, but this time the target is moving
      /// faster than the pursuer, so we expect the agent will never catch up.
      /// Thus, this function returns the distance between the target and the
      /// agent after the [duration] seconds. The capture is not simulated
      /// (even if the pursuer is lucky and the target moves straight at them).
      Future<double> simulateSlowPursuit({
        required Vector2 targetPosition,
        required Vector2 targetVelocity,
        required Vector2 agentInitialVelocity,
        required double maxSpeed,
        required double maxAcceleration,
        double dt = 0.02,
        double duration = 50,
      }) async {
        assert(
          maxSpeed <= targetVelocity.length,
          'Max speed of the agent must be less than the speed of the target',
        );
        final target = SteerableComponent(
          position: targetPosition,
          velocity: targetVelocity,
        );
        final agent = SteerableComponent(velocity: agentInitialVelocity)
          ..maxLinearSpeed = maxSpeed
          ..maxLinearAcceleration = maxAcceleration
          ..behavior = Pursue(target: target);

        final game = FlameGame()..onGameResize(Vector2.all(1000));
        await game.ensureAdd(target);
        await game.ensureAdd(agent);
        game.update(0);

        var totalTime = 0.0;
        while (totalTime < duration) {
          game.update(dt);
          totalTime += dt;
        }
        return (target.position - agent.position).length;
      }

      test('pursuit 1', () async {
        final distance = await simulateSlowPursuit(
          targetPosition: Vector2(50, 30),
          targetVelocity: Vector2(0, 30),
          agentInitialVelocity: Vector2.zero(),
          maxSpeed: 25,
          maxAcceleration: 20,
        );
        expect(distance, closeTo(302.8, 0.1));
      });

      test('pursuit 2', () async {
        final distance = await simulateSlowPursuit(
          targetPosition: Vector2(50, -20),
          targetVelocity: Vector2(0, 30),
          agentInitialVelocity: Vector2.zero(),
          maxSpeed: 25,
          maxAcceleration: 120,
        );
        expect(distance, closeTo(250.4, 0.1));
      });

      test('pursuit 3', () async {
        final distance = await simulateSlowPursuit(
          targetPosition: Vector2(50, 0),
          targetVelocity: Vector2(0, 30),
          agentInitialVelocity: Vector2.zero(),
          maxSpeed: 30,
          maxAcceleration: 200,
        );
        expect(distance, closeTo(16.2, 0.1));
      });
    });
  });
}
