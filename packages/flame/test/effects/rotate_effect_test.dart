import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/rotate_effect.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RotateEffect', () {
    testWithFlameGame('relative', (game) async {
      final component = PositionComponent();
      await game.ensureAdd(component);

      component.angle = 1;
      component.add(
        RotateEffect.by(1, EffectController(duration: 1)),
      );
      game.update(0);
      expect(component.angle, 1);
      expect(component.children.length, 1);

      game.update(0.5);
      expect(component.angle, 1.5);

      game.update(0.5);
      expect(component.angle, 2);
      game.update(0);
      expect(component.children.length, 0);
      expect(component.angle, 2);
    });

    testWithFlameGame('absolute', (game) async {
      game.onGameResize(Vector2(1, 1));
      final component = PositionComponent();
      await game.ensureAdd(component);

      component.angle = 1;
      component.add(
        RotateEffect.to(3, EffectController(duration: 1)),
      );
      game.update(0);
      expect(component.angle, 1);
      expect(component.children.length, 1);

      game.update(0.5);
      expect(component.angle, 2);

      game.update(0.5);
      expect(component.angle, 3);
      game.update(0);
      expect(component.children.length, 0);
      expect(component.angle, 3);
    });

    testWithFlameGame('reset relative', (game) async {
      final component = PositionComponent();
      await game.ensureAdd(component);

      final effect = RotateEffect.by(1, EffectController(duration: 1));
      component.add(effect..removeOnFinish = false);
      for (var i = 0.0; i < 5; i++) {
        expect(component.angle, i.toNormalizedAngle());
        // After each reset the object will be rotated by 1 radian relative to
        // its orientation at the start of the effect
        effect.reset();
        game.update(1);
        expect(component.angle, (i + 1.0).toNormalizedAngle());
      }
    });

    testWithFlameGame('reset absolute', (game) async {
      final component = PositionComponent();
      await game.ensureAdd(component);

      final effect = RotateEffect.to(1, EffectController(duration: 1));
      component.add(effect..removeOnFinish = false);
      for (var i = 0; i < 5; i++) {
        component.angle = 1 + 4.0 * i;
        // After each reset the object will be rotated to the value of
        // `angle == 1`, regardless of its initial orientation.
        effect.reset();
        game.update(1);
        expect(component.angle, 1);
      }
    });

    testWithFlameGame('rotation composition', (game) async {
      final component = PositionComponent();
      await game.ensureAdd(component);

      component.add(
        RotateEffect.by(5, EffectController(duration: 10)),
      );
      component.add(
        RotateEffect.by(
          0.5,
          EffectController(
            duration: 1,
            reverseDuration: 1,
            repeatCount: 5,
          ),
        ),
      );

      game.update(1);
      expect(component.angle, closeTo(1, 1e-15)); // 5*1/10 + 0.5*1
      game.update(1);
      expect(component.angle, closeTo(1, 1e-15)); // 5*2/10 + 0.5*1 - 0.5*1
      for (var i = 0; i < 10; i++) {
        game.update(1);
      }
      expect(component.angle, closeTo(5.0.toNormalizedAngle(), 1e-15));
      expect(component.children.length, 0);
    });

    testRandom('a very long rotation', (Random rng) async {
      final game = await initializeFlameGame();
      final component = PositionComponent();
      await game.ensureAdd(component);

      final effect = RotateEffect.by(
        1.0,
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
      // Typically, `object.angle` could accumulate numeric discrepancy on the
      // order of 1e-11 .. 1e-12 by now.
      expect(component.angle, closeTo(0, 1e-10));
    });
  });
}
