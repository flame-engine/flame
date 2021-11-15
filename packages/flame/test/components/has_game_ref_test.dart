import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
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
  final withHasGameRef = FlameTester(() => _MyGame());

  group('HasGameRef', () {
    withHasGameRef.test('simple test', (game) {
      final c = _MyComponent();
      game.add(c);
      c.foo();
      expect(game.calledFoo, true);
    });
  });
}
