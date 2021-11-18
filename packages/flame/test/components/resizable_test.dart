import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _MyComponent extends PositionComponent {
  String name;
  late Vector2 gameSize;

  _MyComponent(this.name) : super(size: Vector2.all(2.0));

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    this.gameSize = gameSize;
  }
}

void main() {
  final size = Vector2(1.0, 1.0);
  // These tests do not use FlameTester since we want to call `onGameResize`
  // manually in them.
  group('resizable test', () {
    test('game calls resize on add', () async {
      final a = _MyComponent('a');
      final game = FlameGame();
      game.onGameResize(size);

      await game.ensureAdd(a);
      expect(a.gameSize, size);
    });

    test('game calls resize after added', () async {
      final a = _MyComponent('a');
      final game = FlameGame();
      game.onGameResize(Vector2.all(10));

      await game.ensureAdd(a);
      game.onGameResize(size);
      expect(a.gameSize, size);
    });

    test("game calls doesn't change component size", () async {
      final a = _MyComponent('a');
      final game = FlameGame();
      game.onGameResize(Vector2.all(10));

      await game.ensureAdd(a);
      game.onGameResize(size);
      expect(a.size, isNot(size));
    });
  });
}
