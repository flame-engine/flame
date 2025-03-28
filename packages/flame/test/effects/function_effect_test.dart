import 'package:flame/components.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/function_effect.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FunctionEffect', () {
    testWithFlameGame('applies function correctly', (game) async {
      final effect = FunctionEffect<PositionComponent>(
        (target, progress) {
          target.x = progress * 100;
        },
        EffectController(duration: 1),
      );
      final component = PositionComponent(children: [effect]);
      await game.ensureAdd(component);

      effect.update(0);
      expect(component.x, 0);

      effect.update(0.5);
      expect(component.x, 50);

      effect.update(0.5);
      expect(component.x, 100);
    });

    testWithFlameGame('completes correctly', (game) async {
      final effect = FunctionEffect<PositionComponent>(
        (target, progress) {
          target.x = progress * 100;
        },
        EffectController(duration: 1),
      );
      final component = PositionComponent(children: [effect]);
      await game.ensureAdd(component);

      effect.update(1);
      expect(component.x, 100);
      expect(effect.controller.completed, true);
    });

    testWithFlameGame('removes on finish', (game) async {
      final effect = FunctionEffect<PositionComponent>(
        (target, progress) {
          target.x = progress * 100;
        },
        EffectController(duration: 1),
      );
      final component = PositionComponent(children: [effect]);
      await game.ensureAdd(component);

      expect(component.children.length, 1);
      game.update(1);
      expect(effect.controller.completed, true);
      game.update(0);
      expect(component.children.length, 0);
    });

    testWithFlameGame('does not remove on finish', (game) async {
      final effect = FunctionEffect<PositionComponent>(
        (target, progress) {
          target.x = progress * 100;
        },
        EffectController(duration: 1),
      );
      effect.removeOnFinish = false;
      final component = PositionComponent(children: [effect]);
      await game.ensureAdd(component);

      expect(component.children.length, 1);
      game.update(1);
      expect(effect.controller.completed, true);
      game.update(0);
      expect(component.children.length, 1);
    });
  });
}
