import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects2/remove_effect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoveEffect', () {
    test('no delay', () {
      final game = FlameGame();
      game.onGameResize(Vector2.all(1));
      expect(game.children.length, 0);
      final obj = Component();
      game.add(obj);
      game.update(0);
      expect(game.children.length, 1);

      // First `game.update()` invokes the destroy effect and schedules `obj`
      // for deletion; second `game.update()` processes the deletion queue and
      // actually removes the component
      obj.add(RemoveEffect());
      game.update(0);
      game.update(0);
      expect(game.children.length, 0);
    });

    test('delayed', () {
      final game = FlameGame();
      game.onGameResize(Vector2.all(1));
      expect(game.children.length, 0);
      final obj = Component();
      game.add(obj);
      game.update(0);
      expect(game.children.length, 1);

      obj.add(RemoveEffect(delay: 1));
      game.update(0.5);
      game.update(0);
      expect(game.children.length, 1);

      game.update(0.5);
      game.update(0);
      expect(game.children.length, 0);
    });
  });
}
