import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class MyComponent extends PositionComponent {
  String name;
  @override
  Vector2 size = Vector2(2.0, 2.0);
  Vector2 gameSize;

  MyComponent(this.name);

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    this.gameSize = gameSize;
  }
}

class MyGame extends BaseGame {}

Vector2 size = Vector2(1.0, 1.0);

void main() {
  group('resizable test', () {
    test('game calls resize on add', () {
      final MyComponent a = MyComponent('a');
      final MyGame game = MyGame();
      game.onResize(size);
      game.add(a);
      expect(a.gameSize, size);
    });
    test('game calls resize after added', () {
      final MyComponent a = MyComponent('a');
      final MyGame game = MyGame();
      game.onResize(Vector2.all(10));
      game.add(a);
      game.onResize(size);
      expect(a.gameSize, size);
    });
    test("game calls doesn't change component size", () {
      final MyComponent a = MyComponent('a');
      final MyGame game = MyGame();
      game.onResize(Vector2.all(10));
      game.add(a);
      game.onResize(size);
      expect(a.size, isNot(size));
    });
  });
}
