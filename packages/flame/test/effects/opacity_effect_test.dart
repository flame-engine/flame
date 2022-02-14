import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/opacity_effect.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _PaintComponent extends Component with HasPaint {}

void main() {
  const _epsilon = 0.004; // 1/255, since alpha only holds 8 bits

  group('OpacityEffect', () {
    flameGame.test('relative', (game) async {
      final component = _PaintComponent();
      await game.ensureAdd(component);

      component.setOpacity(0.2);
      await component.add(
        OpacityEffect.by(0.4, EffectController(duration: 1)),
      );
      game.update(0);
      expect(component.getOpacity(), 0.2);
      expect(component.children.length, 1);

      game.update(0.5);
      expectDouble(component.getOpacity(), 0.4, epsilon: _epsilon);

      game.update(0.5);
      expectDouble(component.getOpacity(), 0.6, epsilon: _epsilon);
      game.update(0);
      expect(component.children.length, 0);
      expectDouble(component.getOpacity(), 0.6, epsilon: _epsilon);
    });

    flameGame.test('absolute', (game) async {
      final component = _PaintComponent();
      await game.ensureAdd(component);

      component.setOpacity(0.2);
      await component.add(
        OpacityEffect.to(0.4, EffectController(duration: 1)),
      );
      game.update(0);
      expect(component.getOpacity(), 0.2);
      expect(component.children.length, 1);

      game.update(0.5);
      expectDouble(component.getOpacity(), 0.3, epsilon: _epsilon);

      game.update(0.5);
      expectDouble(component.getOpacity(), 0.4, epsilon: _epsilon);
      game.update(0);
      expect(component.children.length, 0);
      expectDouble(component.getOpacity(), 0.4, epsilon: _epsilon);
    });

    flameGame.test('reset relative', (game) async {
      final component = _PaintComponent();
      await game.ensureAdd(component);

      // Since we'll have to change with multiples of 255 to not get rounding
      // errors.
      const step = 10 * 1 / 255;
      final effect = OpacityEffect.by(
        -step,
        EffectController(duration: 1),
      );
      component.add(effect..removeOnFinish = false);
      for (var i = 0; i < 5; i++) {
        expectDouble(component.getOpacity(), 1.0 - step * i, epsilon: _epsilon);
        // After each reset the object will have its opacity modified by -10/255
        // relative to its opacity at the start of the effect.
        effect.reset();
        game.update(1);
        expectDouble(
          component.getOpacity(),
          1.0 - step * (i + 1),
          epsilon: _epsilon,
        );
      }
    });

    flameGame.test('reset absolute', (game) async {
      final component = _PaintComponent();
      await game.ensureAdd(component);

      final effect = OpacityEffect.to(
        0.0,
        EffectController(duration: 1),
      );
      component.add(effect..removeOnFinish = false);
      for (var i = 0; i < 5; i++) {
        component.setOpacity(1 - 0.1 * i);
        // After each reset the object will have an opacity value of 0.0
        // regardless of its initial opacity.
        effect.reset();
        game.update(1);
        // TODO(spydon): This is not good, since it sometimes won't hit the
        // minima.
        expectDouble(component.getOpacity(), 0.0, epsilon: _epsilon);
      }
    });

    flameGame.test('opacity composition', (game) async {
      final component = _PaintComponent();
      component.setOpacity(0.0);
      await game.ensureAdd(component);

      await component.add(
        OpacityEffect.by(0.5, EffectController(duration: 10)),
      );
      await component.add(
        OpacityEffect.by(
          0.5,
          EffectController(
            duration: 1,
            reverseDuration: 1,
            repeatCount: 5,
          ),
        ),
      );

      game.update(1);
      expectDouble(
        component.getOpacity(),
        0.55, // 0.5/10 + 0.5*1
        epsilon: _epsilon,
      );
      game.update(1);
      expectDouble(
        component.getOpacity(),
        0.1,
        epsilon: _epsilon,
      ); // 0.5*2/10 + 0.5*1 - 0.5*1
      for (var i = 0; i < 10; i++) {
        game.update(1);
      }
      expectDouble(component.getOpacity(), 0.5, epsilon: _epsilon);
      expect(component.children.length, 0);
    });

    testRandom('a very long opacity change', (Random rng) async {
      final game = FlameGame()..onGameResize(Vector2(1, 1));
      final component = _PaintComponent();
      await game.ensureAdd(component);

      final effect = OpacityEffect.fadeOut(
        EffectController(
          duration: 1,
          reverseDuration: 1,
          infinite: true,
        ),
      );
      await component.add(effect);

      var totalTime = 0.0;
      while (totalTime < 999.9) {
        final dt = rng.nextDouble() * 0.02;
        totalTime += dt;
        game.update(dt);
      }
      game.update(1000 - totalTime);
      // TODO(spydon): The loop above has an average of 100fps.
      // It should change from 0-255 in 1s so it will change alpha with an
      // average of 255/100=2.5 per tick, which should not result in a need of
      // an epsilon value this high.
      expectDouble(component.getOpacity(), 1.0, epsilon: 100 * _epsilon);
    });
  });
}
