import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SingleGameInstance', () {
    test('game instance becomes statically available', () async {
      final game = SingletonGame()
        ..onGameResize(Vector2.all(100))
        ..onMount();
      expect(Component.staticGameInstance, game);
      game.onRemove();
    });

    test('guard against multiple game instances', () async {
      final game = SingletonGame()
        ..onGameResize(Vector2.all(100))
        ..onMount();
      expect(
        FlameGame.new,
        failsAssert(
          "Instance of 'FlameGame' instantiated, while another game "
          "Instance of 'SingletonGame' declares itself to be a singleton",
        ),
      );
      game.onRemove();
    });

    test(
      'Component starts loading before the parent is mounted',
      () async {
        final game = SingletonGame()
          ..onGameResize(Vector2.all(100))
          ..onMount();
        final parent = Component();
        final child = DelayedComponent();
        final future = child.addToParent(parent);
        expect(parent.isMounted, false);
        expect(parent.isLoaded, false);
        expect(child.isMounted, false);
        expect(child.isLoaded, false); // not yet..
        await future;
        expect(parent.isMounted, false);
        expect(child.isLoaded, true);
        expect(child.isMounted, false);

        game.add(parent);
        expect(parent.isLoaded, true);
        await game.ready();
        expect(child.isMounted, true);
      },
    );
  });
}

class DelayedComponent extends Component {
  @override
  Future<void> onLoad() async {
    await Future<int?>.delayed(const Duration(milliseconds: 20));
  }
}

class SingletonGame extends FlameGame with SingleGameInstance {}
