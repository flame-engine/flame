import 'package:flame/extensions.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  final flameTester = FlameTester(TestGame.new);

  group('SeparationBehavior', () {
    flameTester.testGameWidget(
      'calculates the acceleration needed to separate',
      setUp: (game, tester) async {
        final parent = SteerableEntity(
          behaviors: [
            SeparationBehavior(
              [
                SteerableEntity(
                  position: Vector2.all(10),
                  size: Vector2.all(32),
                ),
                SteerableEntity(
                  position: Vector2.all(20),
                  size: Vector2.all(32),
                ),
              ],
              maxDistance: 50,
              maxAcceleration: 10,
            ),
          ],
          position: Vector2.zero(),
          size: Vector2.all(32),
        );
        await game.ensureAdd(parent);
      },
      verify: (game, tester) async {
        final parent = game.firstChild<SteerableEntity>()!;
        game.update(1);

        expect(parent.velocity, closeToVector(Vector2(-29.08, -29.08), 0.01));
      },
    );
  });
}
