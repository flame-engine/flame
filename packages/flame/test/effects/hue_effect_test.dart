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
        HueEffect(pi, EffectController(duration: 1)),
      );

      game.update(0);

      expect(component.children.length, 1);
      // At progress 0, hue matrix should be identity-ish
      // (or at least result in a ColorFilter)
      expect(component.paint.colorFilter, isNotNull);

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
      final effect = HueEffect(pi, EffectController(duration: 1));
      await component.add(effect);

      game.update(0.5);
      expect(component.paint.colorFilter, isNotNull);

      effect.reset();
      expect(component.paint.colorFilter, isNull);
    });
  });
}

class _PaintComponent extends Component with HasPaint {}
