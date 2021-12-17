import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/scale_effect.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScaleEffect', () {
    flameGame.test('relative', (game) {
      final component = PositionComponent();
      game.ensureAdd(component);

      component.add(
        ScaleEffect.by(Vector2.all(2.0), EffectController(duration: 1)),
      );
      game.update(0);
      expectVector2(component.scale, Vector2.all(1.0));
      expect(component.children.length, 1);

      game.update(0.5);
      expectVector2(component.scale, Vector2.all(1.5));

      game.update(0.5);
      expectVector2(component.scale, Vector2.all(2.0));
      game.update(0);
      expect(component.children.length, 0);
      expectVector2(component.scale, Vector2.all(2.0));
    });

    flameGame.test('absolute', (game) {
      final component = PositionComponent();
      game.ensureAdd(component);

      component.scale = Vector2.all(1.0);
      component.add(
        ScaleEffect.to(Vector2.all(3.0), EffectController(duration: 1)),
      );
      game.update(0);
      expectVector2(component.scale, Vector2.all(1.0));
      expect(component.children.length, 1);

      game.update(0.5);
      expectVector2(component.scale, Vector2.all(2.0));

      game.update(0.5);
      expectVector2(component.scale, Vector2.all(3.0));
      game.update(0);
      expect(component.children.length, 0);
      expectVector2(component.scale, Vector2.all(3.0));
    });

    flameGame.test('reset relative', (game) {
      final component = PositionComponent();
      game.ensureAdd(component);

      final effect = ScaleEffect.by(
        Vector2.all(2.0),
        EffectController(duration: 1),
      );
      component.add(effect..removeOnFinish = false);
      final expectedScale = Vector2.all(1.0);
      for (var i = 0; i < 5; i++) {
        expectVector2(component.scale, expectedScale);
        // After each reset the object will be scaled up twice
        // relative to its scale at the start of the effect.
        effect.reset();
        game.update(1);
        expectedScale.multiply(Vector2.all(2));
        expectVector2(component.scale, expectedScale);
      }
    });

    flameGame.test('reset absolute', (game) {
      final component = PositionComponent();
      game.ensureAdd(component);

      final effect = ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 1),
      );
      component.add(effect..removeOnFinish = false);
      for (var i = 0; i < 5; i++) {
        component.scale = Vector2.all(1 + 4.0 * i);
        // After each reset the object will be scaled to the value of
        // `Vector2(1, 1)`, regardless of its initial orientation.
        effect.reset();
        game.update(1);
        expectVector2(component.scale, Vector2.all(1.0));
      }
    });

    flameGame.test('scale composition', (game) {
      final component = PositionComponent()..flipVertically();
      game.ensureAdd(component);

      component.add(
        ScaleEffect.by(Vector2.all(5), EffectController(duration: 10)),
      );
      component.add(
        ScaleEffect.by(
          Vector2.all(0.5),
          EffectController(
            duration: 1,
            reverseDuration: 1,
            repeatCount: 5,
          ),
        ),
      );

      game.update(1);
      expect(component.scale.x, closeTo(0.7, 1e-15)); // (1 + 0.4) * 0.5
      expect(component.scale.y, closeTo(-0.7, 1e-15));
      game.update(1);
      expect(component.scale.x, closeTo(1.8, 1e-15)); // (1 + 2*0.4) * 1
      expect(component.scale.y, closeTo(-1.8, 1e-15));
      for (var i = 0; i < 8; i++) {
        game.update(1);
      }
      expect(component.scale.x, closeTo(5, 1e-15));
      expect(component.scale.y, closeTo(-5, 1e-15));
      game.update(0);
      expect(component.children.length, 0);
    });

    testRandom('a very long scale change', (Random rng) {
      final game = FlameGame()..onGameResize(Vector2(1, 1));
      final component = PositionComponent();
      game.ensureAdd(component);

      final effect = ScaleEffect.by(
        Vector2.all(1.0),
        EffectController(
          duration: 1,
          reverseDuration: 1,
          infinite: true,
        ),
      );
      component.add(effect);

      var totalTime = 0.0;
      while (totalTime < 999.9) {
        final dt = rng.nextDouble() * 0.02;
        totalTime += dt;
        game.update(dt);
      }
      game.update(1000 - totalTime);
      // Typically, `component.scale` could accumulate numeric discrepancy on
      // the order of 1e-11 .. 1e-12 by now.
      expectVector2(component.scale, Vector2.all(1.0), epsilon: 1e-10);
    });
  });
}
