import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class MyComponent extends PositionComponent {
  String name;
  @override
  final Vector2 size = Vector2(2.0, 2.0);
  late Vector2 gameSize;

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
      final a = MyComponent('a');
      final game = MyGame();
      game.onResize(size);

      game.add(a);
      // component is just added on the next iteration
      game.update(0);

      expect(a.gameSize, size);
    });
    test('game calls resize after added', () {
      final a = MyComponent('a');
      final game = MyGame();
      game.onResize(Vector2.all(10));

      game.add(a);
      // component is just added on the next iteration
      game.update(0);

      game.onResize(size);
      expect(a.gameSize, size);
    });
    test("game calls doesn't change component size", () {
      final a = MyComponent('a');
      final game = MyGame();
      game.onResize(Vector2.all(10));

      game.add(a);
      // component is just added on the next iteration
      game.update(0);

      game.onResize(size);
      expect(a.size, isNot(size));
    });
  });
}
