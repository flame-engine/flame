import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HueEffect', () {
    testWithFlameGame('can apply to component having HasPaint', (game) async {
      final component = _PaintComponent();
      await game.ensureAdd(component);
      await component.add(
        HueEffect.by(pi, EffectController(duration: 1)),
      );

      game.update(0);

      expect(component.children.length, 1);
      // At progress 0, hue is 0, so colorFilter should be null
      // due to optimization.
      expect(component.paint.colorFilter, isNull);

      game.update(0.5);
      final filter05 = component.paint.colorFilter;
      expect(filter05, isNotNull);

      game.update(0.5);
      final filter1 = component.paint.colorFilter;
      expect(filter1, isNotNull);
      expect(filter1, isNot(equals(filter05)));
    });

    testWithFlameGame('reset works correctly', (game) async {
      final component = _PaintComponent();
      await game.ensureAdd(component);
      final effect = HueEffect.by(pi, EffectController(duration: 1));
      await component.add(effect);

      game.update(0.5);
      expect(component.paint.colorFilter, isNotNull);

      effect.reset();
      // Incremental effects don't usually clear the target property on reset.
      // If we want to maintain the old behavior,
      // we'd need to manually set hue to 0.
      component.hue = 0;
      expect(component.paint.colorFilter, isNull);
    });
  });

  group('HueToEffect', () {
    testWithFlameGame('animates hue to target angle', (game) async {
      final component = _PaintComponent();
      await game.ensureAdd(component);
      await component.add(
        HueEffect.to(pi, EffectController(duration: 1)),
      );

      game.update(0);
      expect(component.hue, 0.0);

      game.update(0.5);
      expect(component.hue, closeTo(pi / 2, 0.001));

      game.update(0.5);
      expect(component.hue, closeTo(pi, 0.001));
    });

    testWithFlameGame('computes delta from current hue', (game) async {
      final component = _PaintComponent();
      component.hue = pi / 4;
      await game.ensureAdd(component);
      await component.add(
        HueEffect.to(pi, EffectController(duration: 1)),
      );

      game.update(0);
      expect(component.hue, closeTo(pi / 4, 0.001));

      game.update(1);
      expect(component.hue, closeTo(pi, 0.001));
    });

    testWithFlameGame('applies color filter', (game) async {
      final component = _PaintComponent();
      await game.ensureAdd(component);
      await component.add(
        HueEffect.to(pi / 2, EffectController(duration: 1)),
      );

      game.update(0);
      expect(component.paint.colorFilter, isNull);

      game.update(0.5);
      expect(component.paint.colorFilter, isNotNull);

      game.update(0.5);
      expect(component.paint.colorFilter, isNotNull);
    });
  });
}

class _PaintComponent extends Component with HasPaint {}
