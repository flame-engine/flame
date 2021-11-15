import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class _MyGame extends FlameGame {
  bool calledFoo = false;
  void foo() {
    calledFoo = true;
  }
}

class _MyComponent extends Component with HasGameRef<_MyGame> {
  void foo() {
    gameRef.foo();
  }
}

void main() {
  group('HasGameRef', () {
    test('simple test', () {
      final c = _MyComponent();
      final game = _MyGame();
      game.onGameResize(Vector2.all(200));
      game.add(c);
      c.foo();
      expect(game.calledFoo, true);
    });
  });
}
