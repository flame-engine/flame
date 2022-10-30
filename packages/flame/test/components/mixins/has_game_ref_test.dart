import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

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

class MockFlameGame extends Mock implements _MyGame {}

void main() {
  group('HasGameRef', () {
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

      expect(component.gameRef, isA<MockFlameGame>());
    });
  });
}
