import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _Enemy extends PositionComponent with Notifier {}

void main() {
  group('ComponentsNotifier', () {
    testWithFlameGame('correctly have the initial value', (game) async {
      await game.ensureAdd(_Enemy());
      await game.ensureAdd(_Enemy());

      final notifier = game.componentsNotifier<_Enemy>();

      expect(notifier.components.length, equals(2));
    });

    testWithFlameGame('notifies when a component is added', (game) async {
      var called = 0;

      game.componentsNotifier<_Enemy>().addListener(() => called++);

      await game.ensureAdd(_Enemy());

      expect(called, equals(1));
    });

    testWithFlameGame('notifies when a component is added', (game) async {
      var called = 0;

      final component = _Enemy();
      await game.ensureAdd(component);

      game.componentsNotifier<_Enemy>().addListener(() => called++);

      component.removeFromParent();
      await game.ready();

      expect(called, equals(1));
    });

    testWithFlameGame(
      'notifies when a component is manually notified',
      (game) async {
        var called = 0;

        final component = _Enemy();
        await game.ensureAdd(component);

        game.componentsNotifier<_Enemy>().addListener(() => called++);

        component.notifyListeners();

        expect(called, equals(1));
      },
    );

    testWithFlameGame(
      'lazy initializes the notifier',
      (game) async {
        expect(game.notifiers, isEmpty);
        game.componentsNotifier<_Enemy>();
        expect(game.notifiers, isNotEmpty);
      },
    );

    testWithFlameGame(
      'do not add the same type',
      (game) async {
        expect(game.notifiers, isEmpty);
        game.componentsNotifier<_Enemy>();
        game.componentsNotifier<_Enemy>();
        expect(game.notifiers.length, equals(1));
      },
    );

    testWithFlameGame('can listen to parent classes', (game) async {
      var parentCalled = 0;
      var called = 0;

      game.componentsNotifier<PositionComponent>().addListener(
        () => parentCalled++,
      );
      game.componentsNotifier<_Enemy>().addListener(() => called++);

      expect(game.notifiers.length, equals(2));

      await game.ensureAdd(_Enemy());

      expect(called, equals(1));
      expect(parentCalled, equals(1));
    });
  });
}
