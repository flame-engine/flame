import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _PaintComponent extends Component with HasPaint {}

void main() {
  group('ColorEffect', () {
    testWithFlameGame('applies the correct color filter', (game) async {
      final component = _PaintComponent();
      await game.ensureAdd(component);
      const color = Colors.red;
      await component.add(
        ColorEffect(color, const Offset(0, 1), EffectController(duration: 1)),
      );
      game.update(0);
      expect(
        component.paint.colorFilter.toString(),
        // Once https://github.com/flutter/flutter/issues/89433 has been fixed
        // the two equals lines should be swapped and the ColorEffect should go
        // to opacity 0.
        //equals('ColorFilter.mode(Color(0x00f44336), BlendMode.srcATop)'),
        equals('ColorFilter.mode(Color(0x01f44336), BlendMode.srcATop)'),
      );

      game.update(0.5);
      expect(
        component.paint.colorFilter.toString(),
        equals('ColorFilter.mode(Color(0x80f44336), BlendMode.srcATop)'),
      );
    });

    testWithFlameGame(
      'resets the color filter to the original state',
      (game) async {
        final component = _PaintComponent();
        await game.ensureAdd(component);

        final originalColorFilter = component.paint.colorFilter;
        const color = Colors.red;

        final effect = ColorEffect(
          color,
          const Offset(0, 1),
          EffectController(duration: 1),
        );
        await component.add(effect);
        game.update(0.5);

        expect(
          originalColorFilter,
          isNot(equals(component.paint.colorFilter)),
        );

        effect.reset();

        expect(
          originalColorFilter,
          equals(component.paint.colorFilter),
        );
      },
    );
  });
}
