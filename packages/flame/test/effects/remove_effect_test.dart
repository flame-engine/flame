import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoveEffect', () {
    testWithFlameGame('no delay', (game) async {
      final component = Component();
      await game.ensureAdd(component);
      expect(game.children.length, 1);

      // First `game.update()` invokes the destroy effect and schedules
      // `component` for deletion; second `game.update()` processes the deletion
      // queue and actually removes the component.
      component.add(RemoveEffect());
      game.update(0);
      game.update(0);
      expect(game.children.length, 0);
    });

    testWithFlameGame('delayed', (game) async {
      final component = Component();
      await game.ensureAdd(component);
      expect(game.children.length, 1);

      component.add(RemoveEffect(delay: 1));
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
