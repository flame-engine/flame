import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestEntity extends PositionedEntity {
  _TestEntity({super.behaviors}) : super(size: Vector2.all(32));
}

class _TestBehavior extends Behavior<_TestEntity> {}

void main() {
  group('Behavior', () {
    flameGame.testGameWidget(
      'can be added to an Entity',
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
      'contains point is relative to parent',
      setUp: (game, tester) async {
        final behavior = _TestBehavior();
        final entity = _TestEntity(behaviors: [behavior]);
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<_TestEntity>()!;
        final behavior = entity.firstChild<_TestBehavior>()!;

        expect(behavior.containsLocalPoint(Vector2.zero()), isTrue);
        expect(behavior.containsLocalPoint(Vector2(31, 31)), isTrue);
        expect(behavior.containsLocalPoint(Vector2(32, 32)), isFalse);
      },
    );

    flameGame.testGameWidget(
      'contains local point is relative to parent',
      setUp: (game, tester) async {
        final behavior = _TestBehavior();
        final entity = _TestEntity(behaviors: [behavior]);
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<_TestEntity>()!;
        final behavior = entity.firstChild<_TestBehavior>()!;

        expect(behavior.containsLocalPoint(Vector2.zero()), isTrue);
        expect(behavior.containsLocalPoint(Vector2(31, 31)), isTrue);
        expect(behavior.containsLocalPoint(Vector2(32, 32)), isFalse);
      },
    );

    flameGame.testGameWidget(
      'debugMode is provided by the parent',
      setUp: (game, tester) async {
        final behavior = _TestBehavior();
        final entity = _TestEntity(behaviors: [behavior]);
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<_TestEntity>()!;
        final behavior = entity.firstChild<_TestBehavior>()!;

        expect(behavior.debugMode, isFalse);
        entity.debugMode = true;
        expect(behavior.debugMode, isTrue);
      },
    );

    group('children', () {
      late _TestBehavior testBehavior;
      late _TestEntity testEntity;

      setUp(() {
        testBehavior = _TestBehavior();
        testEntity = _TestEntity(behaviors: [testBehavior]);
      });

      flameGame.testGameWidget(
        'can have its own children',
        setUp: (game, tester) async {
          await game.ensureAdd(testEntity);
        },
        verify: (game, tester) async {
          expect(() => testBehavior.add(Component()), returnsNormally);
        },
      );

      flameGame.testGameWidget(
        'can not have behaviors as children',
        setUp: (game, tester) async {
          await game.ensureAdd(testEntity);
        },
        verify: (game, tester) async {
          expect(
            () => testBehavior.add(_TestBehavior()),
            failsAssert('Behaviors cannot have behaviors.'),
          );
        },
      );

      flameGame.testGameWidget(
        'can not have entities as children',
        setUp: (game, tester) async {
          await game.ensureAdd(testEntity);
        },
        verify: (game, tester) async {
          expect(
            () => testBehavior.add(_TestEntity()),
            failsAssert('Behaviors cannot have entities.'),
          );
        },
      );
    });
  });
}
