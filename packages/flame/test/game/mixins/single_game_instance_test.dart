import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SingleGameInstance', () {
    test('game instance becomes statically available', () {
      final game = _SingletonGame()
        ..onGameResize(Vector2.all(100))
        ..onMount();
      expect(Component.staticGameInstance, game);
      game.onRemove();
    });

    test('guard against multiple game instances', () {
      final game = _SingletonGame()
        ..onGameResize(Vector2.all(100))
        ..onMount();
      expect(
        FlameGame.new,
        failsAssert(
          "Instance of 'FlameGame<World>' instantiated, while another game "
          "Instance of '_SingletonGame' declares itself to be a singleton",
        ),
      );
      game.onRemove();
    });

    testWithGame<_SingletonGame>(
      'Component starts loading before the parent is mounted',
      _SingletonGame.new,
      (game) async {
        final parent = Component();
        final child = _DelayedComponent();
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

class _DelayedComponent extends Component {
  @override
  Future<void> onLoad() async {
    await Future<int?>.delayed(const Duration(milliseconds: 20));
  }
}

class _SingletonGame extends FlameGame with SingleGameInstance {}
