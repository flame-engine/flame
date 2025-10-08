import 'package:flame/extensions.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  final flameTester = FlameTester(TestGame.new);

  group('FleeBehavior', () {
    flameTester.testGameWidget(
      'only flee if target is within panic distance',
      setUp: (game, tester) async {
        final target = SteerableEntity();
        final parent = SteerableEntity(
          behaviors: [
            FleeBehavior(
              target,
              maxAcceleration: 100,
              panicDistance: 20,
            ),
          ],
          position: Vector2.zero(),
          size: Vector2.all(32),
        );
        await game.ensureAddAll([parent, target]);
      },
      verify: (game, tester) async {
        final parent = game.children.whereType<SteerableEntity>().first;
        final target = game.children.whereType<SteerableEntity>().last;

        // Move target outside panic distance.
        target.position.setValues(20, 20);
        game.update(1);

        expect(parent.velocity, closeToVector(Vector2(0, 0), 0.01));

        // Move target inside panic distance.
        target.position.setValues(5, 5);
        game.update(1);

        expect(parent.velocity, closeToVector(Vector2(-70.71, -70.71), 0.01));
      },
    );

    flameTester.testGameWidget(
      'render panic distance as a circle in debug mode',
      setUp: (game, tester) async {
        final entity = SteerableEntity(
          behaviors: [
            FleeBehavior(
              SteerableEntity(),
              maxAcceleration: 100,
              panicDistance: 64,
            ),
          ],
          position: game.size / 2,
          size: Vector2.all(32),
        )..debugMode = true;

        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        await tester.pump();

        await expectLater(
          find.byGame<TestGame>(),
          matchesGoldenFile('golden/flee_behavior/render_debug_mode.png'),
        );
      },
    );
  });
}
