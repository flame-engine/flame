import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('HasGameReference', () {
    testWithFlameGame(
      'component with default HasGameReference',
      (game) async {
        final component1 = _Component<FlameGame>();
        final component2 = _Component<Game>();
        game.addAll([component1, component2]);
        expect(component1.game, game);
        expect(component2.game, game);
      },
    );

    testWithGame<_MyGame>(
      'component with typed HasGameReference',
      _MyGame.new,
      (game) async {
        final component = _Component<_MyGame>();
        game.add(component);
        expect(component.game, game);
      },
    );

    testWithFlameGame(
      'game reference accessed too early',
      (game) async {
        final component = _Component();
        expect(
          () => component.game,
          failsAssert(
            'Could not find Game instance: the component is detached from the '
            'component tree',
          ),
        );
      },
    );

    testWithFlameGame(
      'game reference of wrong type',
      (game) async {
        final component = _Component<_MyGame>();
        game.add(component);
        expect(
          () => component.game,
          failsAssert(
            'Found game of type FlameGame, while type _MyGame was expected',
          ),
        );
      },
    );

    testWithFlameGame(
      'game reference can be set explicitly',
      (game) async {
        final component = _Component<FlameGame>();
        component.game = game;
        expect(component.game, game);

        component.game = null;
        expect(
          () => component.game,
          failsAssert(
            'Could not find Game instance: the component is detached from the '
            'component tree',
          ),
        );
      },
    );

    testWithFlameGame(
      'game reference propagates quickly',
      (game) async {
        final component1 = _Component()..addToParent(game);
        final component2 = _Component()..addToParent(component1);
        final component3 = _Component()..addToParent(component2);
        expect(component3.game, game);
      },
    );

    testWithGame<_MyGame>('simple test', _MyGame.new, (game) async {
      final c = _FooComponent();
      game.add(c);
      c.foo();
      expect(game.calledFoo, true);
    });

    testWithGame<_MyGame>('gameRef can be mocked', _MyGame.new, (game) async {
      final component = _BarComponent();
      await game.ensureAdd(component);

      component.game = MockFlameGame();

      expect(component.game, isA<MockFlameGame>());
    });
  });
}

class _Component<T extends Game> extends Component with HasGameReference<T> {}

class _MyGame extends FlameGame {
  bool calledFoo = false;
  void foo() {
    calledFoo = true;
  }
}

class _FooComponent extends Component with HasGameReference<_MyGame> {
  void foo() {
    game.foo();
  }
}

class _BarComponent extends Component with HasGameReference<_MyGame> {}

class MockFlameGame extends Mock implements _MyGame {}
