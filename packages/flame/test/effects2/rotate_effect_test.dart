import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects2/rotate_effect.dart';
import 'package:flame/src/effects2/standard_effect_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RotateEffect', () {
    test('relative', () {
      final game = FlameGame();
      game.onGameResize(Vector2(1, 1));
      final object = PositionComponent();
      game.add(object);
      game.update(0);

      object.angle = 1;
      object.add(
        RotateEffect.by(1, StandardEffectController(duration: 1)),
      );
      game.update(0);
      expect(object.angle, 1);
      expect(object.children.length, 1);

      game.update(0.5);
      expect(object.angle, 1.5);

      game.update(0.5);
      expect(object.angle, 2);
      game.update(0);
      expect(object.children.length, 0);
      expect(object.angle, 2);
    });

    test('absolute', () {
      final game = FlameGame();
      game.onGameResize(Vector2(1, 1));
      final object = PositionComponent();
      game.add(object);
      game.update(0);

      object.angle = 1;
      object.add(
        RotateEffect.to(3, StandardEffectController(duration: 1)),
      );
      game.update(0);
      expect(object.angle, 1);
      expect(object.children.length, 1);

      game.update(0.5);
      expect(object.angle, 2);

      game.update(0.5);
      expect(object.angle, 3);
      game.update(0);
      expect(object.children.length, 0);
      expect(object.angle, 3);
    });

    test('reset relative', () {
      final game = FlameGame()..onGameResize(Vector2(1, 1));
      final object = PositionComponent();
      game.add(object);
      game.update(0);

      final effect = RotateEffect.by(1, StandardEffectController(duration: 1));
      object.add(effect..removeOnFinish = false);
      for (var i = 0; i < 5; i++) {
        expect(object.angle, i);
        // After each reset the object will be rotated by 1 radian relative to
        // its orientation at the start of the effect
        effect.reset();
        game.update(1);
        expect(object.angle, i + 1);
      }
    });

    test('reset absolute', () {
      final game = FlameGame()..onGameResize(Vector2(1, 1));
      final object = PositionComponent();
      game.add(object);
      game.update(0);

      final effect = RotateEffect.to(1, StandardEffectController(duration: 1));
      object.add(effect..removeOnFinish = false);
      for (var i = 0; i < 5; i++) {
        object.angle = 1 + 4.0 * i;
        // After each reset the object will be rotated to the value of
        // `angle == 1`, regardless of its initial orientation.
        effect.reset();
        game.update(1);
        expect(object.angle, 1);
      }
    });

    test('rotation composition', () {
      final game = FlameGame()..onGameResize(Vector2(1, 1));
      final object = PositionComponent();
      game.add(object);
      game.update(0);

      object.add(
        RotateEffect.by(5, StandardEffectController(duration: 10)),
      );
      object.add(
        RotateEffect.by(
          0.5,
          StandardEffectController(
            duration: 1,
            reverseDuration: 1,
            repeatCount: 5,
          ),
        ),
      );

      game.update(1);
      expect(object.angle, closeTo(1, 1e-15)); // 5*1/10 + 0.5*1
      game.update(1);
      expect(object.angle, closeTo(1, 1e-15)); // 5*2/10 + 0.5*1 - 0.5*1
      for (var i = 0; i < 10; i++) {
        game.update(1);
      }
      expect(object.angle, closeTo(5, 1e-15));
      expect(object.children.length, 0);
    });

    testRandom('a very long rotation', (Random rng) {
      final game = FlameGame()..onGameResize(Vector2(1, 1));
      final object = PositionComponent();
      game.add(object);
      game.update(0);

      final effect = RotateEffect.by(
        1.0,
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
      // Typically, `object.angle` could accumulate numeric discrepancy on the
      // order of 1e-11 .. 1e-12 by now.
      expect(object.angle, closeTo(0, 1e-10));
    });
  });
}
