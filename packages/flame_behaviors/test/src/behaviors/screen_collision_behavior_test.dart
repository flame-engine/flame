import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _Entity extends PositionedEntity {
  _Entity({super.behaviors, super.position})
    : super(size: Vector2.all(16), anchor: Anchor.center);
}

class _TrackingScreenCollisionBehavior
    extends ScreenCollisionBehavior<_Entity> {
  bool startCalled = false;
  bool collisionCalled = false;
  bool endCalled = false;
  ScreenHitbox? lastOther;

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, ScreenHitbox other) {
    super.onCollisionStart(intersectionPoints, other);
    startCalled = true;
    lastOther = other;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, ScreenHitbox other) {
    super.onCollision(intersectionPoints, other);
    collisionCalled = true;
  }

  @override
  void onCollisionEnd(ScreenHitbox other) {
    super.onCollisionEnd(other);
    endCalled = true;
  }
}

class _TestGame extends FlameGame with HasCollisionDetection {
  _TestGame() : super(children: [ScreenHitbox()]);
}

void main() {
  final flameTester = FlameTester(_TestGame.new);

  group('$ScreenCollisionBehavior', () {
    flameTester.testGameWidget(
      'fires onCollisionStart when entity touches the screen edge, '
      'with the ScreenHitbox passed through',
      setUp: (game, tester) async {
        await game.ready();
        final behavior = _TrackingScreenCollisionBehavior();
        final entity = _Entity(
          behaviors: [
            PropagatingCollisionBehavior(RectangleHitbox()),
            behavior,
          ],
          position: Vector2(0, game.size.y / 2),
        );
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<_Entity>()!;
        final behavior = entity.firstChild<_TrackingScreenCollisionBehavior>()!;

        game.update(0);

        expect(behavior.startCalled, isTrue);
        expect(behavior.collisionCalled, isTrue);
        expect(behavior.lastOther, isA<ScreenHitbox>());
      },
    );

    flameTester.testGameWidget(
      'fires onCollisionEnd when entity leaves the screen edge',
      setUp: (game, tester) async {
        await game.ready();
        final behavior = _TrackingScreenCollisionBehavior();
        final entity = _Entity(
          behaviors: [
            PropagatingCollisionBehavior(RectangleHitbox()),
            behavior,
          ],
          position: Vector2(0, game.size.y / 2),
        );
        await game.ensureAdd(entity);
      },
      verify: (game, tester) async {
        final entity = game.firstChild<_Entity>()!;
        final behavior = entity.firstChild<_TrackingScreenCollisionBehavior>()!;

        game.update(0);
        expect(behavior.startCalled, isTrue);
        expect(behavior.endCalled, isFalse);

        entity.position = game.size / 2;
        game.update(0);

        expect(behavior.endCalled, isTrue);
      },
    );

    flameTester.testGameWidget(
      'does not fire when colliding with a non-screen hitbox',
      setUp: (game, tester) async {
        await game.ready();
        final behavior = _TrackingScreenCollisionBehavior();
        final entity = _Entity(
          behaviors: [
            PropagatingCollisionBehavior(RectangleHitbox()),
            behavior,
          ],
          position: game.size / 2,
        );
        final other = _Entity(
          behaviors: [PropagatingCollisionBehavior(RectangleHitbox())],
          position: game.size / 2,
        );
        await game.ensureAdd(entity);
        await game.ensureAdd(other);
      },
      verify: (game, tester) async {
        final entity = game.firstChildWhere<_Entity>(
          (e) => e.firstChild<_TrackingScreenCollisionBehavior>() != null,
        )!;
        final behavior = entity.firstChild<_TrackingScreenCollisionBehavior>()!;

        game.update(0);

        expect(behavior.startCalled, isFalse);
        expect(behavior.collisionCalled, isFalse);
      },
    );
  });
}

extension on FlameGame {
  T? firstChildWhere<T extends Component>(bool Function(T) test) {
    for (final c in children.whereType<T>()) {
      if (test(c)) {
        return c;
      }
    }
    return null;
  }
}
