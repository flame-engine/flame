import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
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

    testWithFlameGame('as a part of a sequence', (game) async {
      final component = PositionComponent();
      await game.ensureAdd(component);
      component.add(
        SequenceEffect([
          MoveByEffect(Vector2.all(10), EffectController(duration: 1)),
          RemoveEffect(),
        ]),
      );
      game.update(0);
      expect(game.children.length, 1);
      game.update(0.5);
      expect(game.children.length, 1);
      game.update(1.0); // This completes the move effect
      game.update(0); // This runs the remove effect
      expect(game.children.length, 0);
    });
  });
}
