// ignore_for_file: deprecated_member_use_from_same_package

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

class _FooComponent extends Component with HasGameReference<_MyGame> {
  void foo() {
    game.foo();
  }
}

class _BarComponent extends Component with HasGameReference<_MyGame> {}

class _MockFlameGame extends Mock implements _MyGame {}

void main() {
  group('HasGameReference', () {
    testWithGame<_MyGame>('simple test', _MyGame.new, (game) async {
      final c = _FooComponent();
      game.add(c);
      c.foo();
      expect(game.calledFoo, true);
    });

    testWithGame<_MyGame>('game can be mocked', _MyGame.new, (game) async {
      final component = _BarComponent();
      await game.ensureAdd(component);

      component.game = _MockFlameGame();

      expect(component.game, isA<_MockFlameGame>());
    });
  });
}
