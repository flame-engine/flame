import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

class _TestEntity extends Entity {
  _TestEntity({super.behaviors});
}

class _TestBehavior extends Behavior<_TestEntity> {}

void main() {
  group('Entity', () {
    flameGame.testGameWidget(
      'adds behaviors directly to itself',
      setUp: (game, tester) async {
        final behavior = _TestBehavior();
        final entity = _TestEntity(behaviors: [behavior]);
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<_TestEntity>()!;

        expect(game.descendants().whereType<_TestBehavior>().length, equals(1));
        expect(entity.children.whereType<_TestBehavior>().length, equals(1));
      },
    );

    flameGame.testGameWidget(
      'adds behaviors to itself',
      setUp: (game, tester) async {
        final behavior = _TestBehavior();
        final entity = _TestEntity();
        await entity.add(behavior);
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<_TestEntity>()!;

        expect(game.descendants().whereType<_TestBehavior>().length, equals(1));
        expect(entity.children.whereType<_TestBehavior>().length, equals(1));
      },
    );

    flameGame.testGameWidget(
      'behavior can be removed from entity and the internal cache',
      setUp: (game, tester) async {
        final entity = _TestEntity(behaviors: []);
        await game.ensureAdd(entity);

        final behavior = _TestBehavior();
        expect(
          entity.findBehavior<_TestBehavior>,
          throwsBehaviorNotFoundFor<_TestBehavior>(),
        );
        await entity.ensureAdd(behavior);
        expect(entity.findBehavior<_TestBehavior>(), isNotNull);
        behavior.removeFromParent();
      },
      verify: (game, tester) async {
        final entity = game.firstChild<_TestEntity>()!;

        expect(
          entity.findBehavior<_TestBehavior>,
          throwsBehaviorNotFoundFor<_TestBehavior>(),
        );
      },
    );

    flameGame.testGameWidget(
      'can correctly confirm if it has a behavior',
      setUp: (game, tester) async {
        final entity = _TestEntity(behaviors: []);
        final behavior = _TestBehavior();
        await game.ensureAdd(entity);

        expect(entity.hasBehavior<_TestBehavior>(), isFalse);
        await entity.ensureAdd(behavior);
        expect(entity.hasBehavior<_TestBehavior>(), isTrue);

        behavior.removeFromParent();
      },
      verify: (game, tester) async {
        final entity = game.firstChild<_TestEntity>()!;

        expect(entity.hasBehavior<_TestBehavior>(), isFalse);
      },
    );
  });
}
