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
        ColorEffect(color, EffectController(duration: 1)),
      );
      game.update(0);
      expect(
        component.paint.colorFilter.toString(),
        equals(
          'ColorFilter.mode(Color(alpha: 0.0000, red: 0.9569, green: '
          '0.2627, blue: 0.2118, colorSpace: ColorSpace.sRGB),'
          ' BlendMode.srcATop)',
        ),
      );

      game.update(0.5);
      expect(
        component.paint.colorFilter.toString(),
        equals(
          'ColorFilter.mode(Color(alpha: 0.5000, red: 0.9569, green: '
          '0.2627, blue: 0.2118, colorSpace: ColorSpace.sRGB), '
          'BlendMode.srcATop)',
        ),
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

    testWithFlameGame(
      'resets the color filter to the original state',
      (game) async {
        final component = _PaintComponent();
        await game.ensureAdd(component);

        final originalColorFilter = component.paint.colorFilter;
        const color = Colors.red;

        final effect = ColorEffect(
          color,
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

    testWithFlameGame(
      'can be re-added in the component tree',
      (game) async {
        final component = _PaintComponent();
        await game.ensureAdd(component);

        final effect = ColorEffect(
          Colors.red,
          EffectController(duration: 1),
        );
        await component.ensureAdd(effect);
        game.update(0.5);
        effect.removeFromParent();
        game.update(0.0);
        component.add(effect);
        expect(
          () => game.update(0),
          returnsNormally,
        );
      },
    );

    testWithFlameGame(
      'will clamp controllers that over or under set the progress value',
      (game) async {
        final component = _PaintComponent();
        await game.ensureAdd(component);

        final effect = ColorEffect(
          opacityFrom: 1,
          opacityTo: 0,
          Colors.black,
          ZigzagEffectController(
            period: 1,
          ),
        );
        await component.ensureAdd(effect);
        expect(
          () => game.update(0.56),
          returnsNormally,
        );
      },
    );

    test('Validates opacity values', () {
      expect(
        () => ColorEffect(
          Colors.blue,
          EffectController(duration: 1),
          opacityTo: 1.1,
        ),
        throwsAssertionError,
      );

      expect(
        () => ColorEffect(
          Colors.blue,
          EffectController(duration: 1),
          opacityFrom: 255,
        ),
        throwsAssertionError,
      );

      expect(
        () => ColorEffect(
          Colors.blue,
          EffectController(duration: 1),
          opacityTo: -254,
        ),
        throwsAssertionError,
      );

      expect(
        () => ColorEffect(
          Colors.blue,
          EffectController(duration: 1),
          opacityFrom: -0.5,
        ),
        throwsAssertionError,
      );

      expect(
        () => ColorEffect(
          Colors.blue,
          EffectController(duration: 1),
          opacityFrom: 0.1,
          opacityTo: 0.9,
        ),
        returnsNormally,
      );
    });
  });
}
