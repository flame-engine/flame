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
  final withHasGameRef = FlameTester(_MyGame.new);

  group('HasGameRef', () {
    withHasGameRef.test('simple test', (game) {
      final c = _FooComponent();
      game.add(c);
      c.foo();
      expect(game.calledFoo, true);
    });

    withHasGameRef.test('gameRef can be mocked', (game) async {
      final component = _BarComponent();
      await game.ensureAdd(component);

      component.mockGameRef(MockFlameGame());

      expect(component.gameRef, isA<MockFlameGame>());
    });
  });
}
