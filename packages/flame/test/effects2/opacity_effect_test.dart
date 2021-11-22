import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects2/opacity_effect.dart';
import 'package:flame/src/effects2/standard_effect_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _PaintComponent extends Component with HasPaint {}

void main() {
  const _epsilon = 0.004; // 1/255, since alpha only holds 8 bits

  group('OpacityEffect', () {
    flameGame.test('relative', (game) {
      final component = _PaintComponent();
      game.ensureAdd(component);

      component.setOpacity(0.2);
      component.add(
        OpacityEffect.by(0.4, StandardEffectController(duration: 1)),
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

    flameGame.test('absolute', (game) {
      final component = _PaintComponent();
      game.ensureAdd(component);

      component.setOpacity(0.2);
      component.add(
        OpacityEffect.to(0.4, StandardEffectController(duration: 1)),
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

    // Since we can't accumulate rounding errors between resets we will get
    // a slightly bigger discrepancy here.
    flameGame.test('reset relative', (game) {
      final component = _PaintComponent();
      game.ensureAdd(component);

      final effect = OpacityEffect.by(
        -0.1,
        StandardEffectController(duration: 1),
      );
      component.add(effect..removeOnFinish = false);
      for (var i = 0.0; i < 0.5; i += 0.1) {
        expectDouble(component.getOpacity(), 1.0 - i, epsilon: 3 * _epsilon);
        // After each reset the object will have its opacity modified by 0.1
        // relative to its opacity at the start of the effect.
        effect.reset();
        game.update(1);
        expectDouble(component.getOpacity(), 0.9 - i, epsilon: 3 * _epsilon);
      }
    });

    flameGame.test('reset absolute', (game) {
      final component = _PaintComponent();
      game.ensureAdd(component);

      final effect = OpacityEffect.to(
        0.0,
        StandardEffectController(duration: 1),
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

    flameGame.test('opacity composition', (game) {
      final component = _PaintComponent();
      component.setOpacity(0.0);
      game.add(component);
      game.update(0);

      component.add(
        OpacityEffect.by(0.5, StandardEffectController(duration: 10)),
      );
      component.add(
        OpacityEffect.by(
          0.5,
          StandardEffectController(
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

    testRandom('a very long opacity change', (Random rng) {
      final game = FlameGame()..onGameResize(Vector2(1, 1));
      final object = _PaintComponent();
      game.ensureAdd(object);

      final effect = OpacityEffect.by(
        -1.0,
        StandardEffectController(
          duration: 1,
          reverseDuration: 1,
          infinite: true,
        ),
      );
      object.add(effect);

      var totalTime = 0.0;
      while (totalTime < 999.9) {
        final dt = rng.nextDouble() * 0.02;
        totalTime += dt;
        game.update(dt);
      }
      game.update(1000 - totalTime);
      expectDouble(object.getOpacity(), 1.0);
    });
  });
}
