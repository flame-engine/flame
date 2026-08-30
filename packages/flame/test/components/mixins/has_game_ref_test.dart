import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _GameRefGame extends FlameGame {}

void main() {
  group('HasGameRef', () {
    testWithGame(
      'component with default HasGameRef',
      _GameRefGame.new,
      (game) async {
        final component1 = _Component<FlameGame>();
        final component2 = _Component<_GameRefGame>();
        game.addAll([component1, component2]);
        expect(component1.gameRef, game);
        expect(component2.gameRef, game);
      },
    );

    testWithGame<_MyGame>(
      'component with typed HasGameRef',
      _MyGame.new,
      (game) async {
        final component = _Component<_MyGame>();
        game.add(component);
        expect(component.gameRef, game);
      },
    );

    testWithFlameGame(
      'game reference accessed too early',
      (game) async {
        final component = _Component();
        expect(
          () => component.gameRef,
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
          () => component.gameRef,
          failsAssert(
            'Found game of type FlameGame<World>, while type _MyGame was '
            'expected',
          ),
        );
      },
    );

    testWithFlameGame(
      'game reference can be set explicitly',
      (game) async {
        final component = _Component<FlameGame>();
        component.gameRef = game;
        expect(component.gameRef, game);

        component.gameRef = null;
        expect(
          () => component.gameRef,
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
        expect(component3.gameRef, game);
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

      component.gameRef = _MockFlameGame();

      expect(component.gameRef, isA<_MockFlameGame>());
    });
  });
}

class _Component<T extends FlameGame> extends Component with HasGameRef<T> {}

class _MyGame extends FlameGame {
  bool calledFoo = false;
  void foo() {
    calledFoo = true;
  }
}

class _FooComponent extends Component with HasGameRef<_MyGame> {
  void foo() {
    gameRef.foo();
  }
}

class _BarComponent extends Component with HasGameRef<_MyGame> {}

class _MockFlameGame extends Mock implements _MyGame {}
