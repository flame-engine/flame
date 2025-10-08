// Not needed for test files
// ignore_for_file: prefer_const_constructors
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  final flameTester = FlameTester(TestGame.new);

  group('Steerable', () {
    flameTester.testGameWidget(
      'add velocity delta to position and subtract the delta from velocity',
      setUp: (game, tester) async {
        final entity = SteerableEntity();
        entity.velocity.setValues(100, 100);
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<SteerableEntity>()!;
        game.update(0.25);

        expect(entity.velocity, closeToVector(Vector2(75, 75)));
        expect(entity.position, closeToVector(Vector2(25, 25)));
      },
    );
  });
}
