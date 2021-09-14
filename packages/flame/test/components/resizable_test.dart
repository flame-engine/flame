import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class MyComponent extends PositionComponent {
  String name;
  late Vector2 gameSize;

  MyComponent(this.name) : super(size: Vector2.all(2.0));

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    this.gameSize = gameSize;
  }
}

Vector2 size = Vector2(1.0, 1.0);

void main() {
  group('resizable test', () {
    test('game calls resize on add', () async {
      final a = MyComponent('a');
      final game = FlameGame();
      game.onGameResize(size);

      await game.add(a);
      // component is just added on the next iteration
      game.update(0);

      expect(a.gameSize, size);
    });

    test('game calls resize after added', () async {
      final a = MyComponent('a');
      final game = FlameGame();
      game.onGameResize(Vector2.all(10));

      await game.add(a);
      // component is just added on the next iteration
      game.update(0);

      game.onGameResize(size);
      expect(a.gameSize, size);
    });

    test("game calls doesn't change component size", () async {
      final a = MyComponent('a');
      final game = FlameGame();
      game.onGameResize(Vector2.all(10));

      await game.add(a);
      // component is just added on the next iteration
      game.update(0);

      game.onGameResize(size);
      expect(a.size, isNot(size));
    });
  });
}
