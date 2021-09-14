import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class MyGame extends FlameGame {
  bool calledFoo = false;
  void foo() {
    calledFoo = true;
  }
}

class MyComponent extends PositionComponent with HasGameRef<MyGame> {
  void foo() {
    gameRef.foo();
  }
}

void main() {
  group('has game ref test', () {
    test('simple test', () {
      final c = MyComponent();
      final game = MyGame();
      game.onGameResize(Vector2.all(200));
      game.add(c);
      c.foo();
      expect(game.calledFoo, true);
    });
  });
}
