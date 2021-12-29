import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/size_effect.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SizeEffect', () {
    flameGame.test('relative', (game) {
      final component = PositionComponent();
      game.ensureAdd(component);

      component.size = Vector2.all(1.0);
      component.add(
        SizeEffect.by(Vector2.all(1.0), EffectController(duration: 1)),
      );
      game.update(0);
      expect(component.size, closeToVector(1, 1));
      expect(component.children.length, 1);

      game.update(0.5);
      expect(component.size, closeToVector(1.5, 1.5));

      game.update(0.5);
      expect(component.size, closeToVector(2, 2));
      game.update(0);
      expect(component.children.length, 0);
      expect(component.size, closeToVector(2, 2));
    });

    flameGame.test('absolute', (game) {
      final component = PositionComponent();
      game.ensureAdd(component);

      component.size = Vector2.all(1.0);
      component.add(
        SizeEffect.to(Vector2.all(3.0), EffectController(duration: 1)),
      );
      game.update(0);
      expect(component.size, closeToVector(1, 1));
      expect(component.children.length, 1);

      game.update(0.5);
      expect(component.size, closeToVector(2, 2));

      game.update(0.5);
      expect(component.size, closeToVector(3, 3));
      game.update(0);
      expect(component.children.length, 0);
      expect(component.size, closeToVector(3, 3));
    });

    flameGame.test('reset relative', (game) {
      final component = PositionComponent();
      game.ensureAdd(component);

      final effect = SizeEffect.by(
        Vector2.all(1.0),
        EffectController(duration: 1),
      );
      component.add(effect..removeOnFinish = false);
      final expectedSize = Vector2.zero();
      for (var i = 0; i < 5; i++) {
        // After each reset the object will be sized up by Vector2(1, 1)
        // relative to its size at the start of the effect.
        effect.reset();
        game.update(1);
        expectedSize.add(Vector2.all(1.0));
        expect(component.size, closeToVector(expectedSize.x, expectedSize.y));
      }
    });

    flameGame.test('reset absolute', (game) {
      final component = PositionComponent();
      game.ensureAdd(component);

      final effect = SizeEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 1),
      );
      component.add(effect..removeOnFinish = false);
      for (var i = 0; i < 5; i++) {
        component.size = Vector2.all(1 + 4.0 * i);
        // After each reset the object will be sized to the value of
        // `Vector2(1, 1)`, regardless of its initial orientation.
        effect.reset();
        game.update(1);
        expect(component.size, closeToVector(1, 1));
      }
    });

    flameGame.test('size composition', (game) {
      final component = PositionComponent();
      game.ensureAdd(component);

      component.add(
        SizeEffect.by(Vector2.all(5), EffectController(duration: 10)),
      );
      component.add(
        SizeEffect.by(
          Vector2.all(0.5),
          EffectController(
            duration: 1,
            reverseDuration: 1,
            repeatCount: 5,
          ),
        ),
      );

      game.update(1);
      expect(component.size, closeToVector(1, 1)); // 5*1/10 + 0.5*1
      game.update(1);
      expect(component.size, closeToVector(1, 1)); // 5*2/10 + 0.5*1 - 0.5*1
      for (var i = 0; i < 10; i++) {
        game.update(1);
      }
      expect(component.size, closeToVector(5, 5));
      expect(component.children.length, 0);
    });

    testRandom('a very long size change', (Random rng) {
      final game = FlameGame()..onGameResize(Vector2(1, 1));
      final component = PositionComponent();
      game.ensureAdd(component);

      final effect = SizeEffect.by(
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
      // Typically, `component.size` could accumulate numeric discrepancy on the
      // order of 1e-11 .. 1e-12 by now.
      expect(component.size, closeToVector(0, 0, epsilon: 1e-10));
    });
  });
}
