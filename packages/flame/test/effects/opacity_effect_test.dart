import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class _PaintComponent extends Component with HasPaint {}

class _CustomPaintComponent<T extends Object> extends Component
    with HasPaint<T> {
  _CustomPaintComponent(Map<T, Paint> paints) {
    for (final p in paints.entries) {
      setPaint(p.key, p.value);
    }
  }
}

enum _PaintTypes { paint1, paint2, paint3 }

void main() {
  const _epsilon = 0.004; // 1/255, since alpha only holds 8 bits

  group('OpacityEffect', () {
    testWithFlameGame('relative', (game) async {
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

    testWithFlameGame('absolute', (game) async {
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

    testWithFlameGame('reset relative', (game) async {
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

    testWithFlameGame('reset absolute', (game) async {
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
        expect(component.getOpacity(), 0.0);
      }
    });

    testWithFlameGame('opacity composition', (game) async {
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

    testWithFlameGame(
      'fade out',
      (game) async {
        final rng = Random();
        final component = _PaintComponent();
        await game.ensureAdd(component);

        // Repeat the test 3 times
        for (var i = 0; i < 3; ++i) {
          await component
              .add(OpacityEffect.fadeOut(EffectController(duration: 3)));

          var timeElapsed = 0.0;
          while (timeElapsed < 3) {
            final dt = rng.nextDouble() / 60;
            game.update(dt);
            timeElapsed += dt;
          }

          expect(component.getOpacity(), 0.0);
          component.setOpacity(1.0);
        }
      },
    );

    testWithFlameGame(
      'infinite fade out',
      (game) async {
        final component = _PaintComponent();
        await game.ensureAdd(component);

        await component.add(
          OpacityEffect.fadeOut(
            EffectController(
              duration: 3,
              infinite: true,
            ),
          ),
        );

        for (var i = 0; i < 100; ++i) {
          game.update(3);
          expectDouble(component.getOpacity(), 0.0);
        }
      },
    );

    testWithFlameGame(
      'on custom paint',
      (game) async {
        final component = _CustomPaintComponent<String>(
          {'bluePaint': BasicPalette.blue.paint()},
        );
        await game.ensureAdd(component);

        await component.add(
          OpacityEffect.fadeOut(
            EffectController(duration: 1),
            target: component.opacityProviderOf('bluePaint'),
          ),
        );

        game.update(1);

        expect(component.getPaint('bluePaint').color.opacity, isZero);

        // RGB components shouldn't be affected after opacity efffect.
        expect(component.getPaint('bluePaint').color.blue, 255);
        expect(component.getPaint('bluePaint').color.red, isZero);
        expect(component.getPaint('bluePaint').color.green, isZero);
      },
    );

    testWithFlameGame(
      'apply on all paints',
      (game) async {
        final component = _CustomPaintComponent<_PaintTypes>(
          {
            _PaintTypes.paint1: BasicPalette.red.paint(),
            _PaintTypes.paint2: BasicPalette.green.paint(),
            _PaintTypes.paint3: BasicPalette.blue.paint(),
          },
        );
        await game.ensureAdd(component);

        await component
            .add(OpacityEffect.fadeOut(EffectController(duration: 1)));

        game.update(1);

        // All paints should have the same opacity after the effect completes.
        expect(component.getPaint().color.opacity, isZero);
        expect(component.getPaint(_PaintTypes.paint1).color.opacity, isZero);
        expect(component.getPaint(_PaintTypes.paint2).color.opacity, isZero);
        expect(component.getPaint(_PaintTypes.paint3).color.opacity, isZero);
      },
    );

    testWithFlameGame(
      'maintains opacity ratios',
      (game) async {
        const redInitialOpacity = 0.9;
        const greenInitialOpacity = 0.5;
        const blueInitialOpacity = 0.2;
        const targetOpacity = 0.5;

        final component = _CustomPaintComponent<_PaintTypes>(
          {
            _PaintTypes.paint1: BasicPalette.red.paint()
              ..color = BasicPalette.green
                  .paint()
                  .color
                  .withOpacity(redInitialOpacity),
            _PaintTypes.paint2: BasicPalette.green.paint()
              ..color = BasicPalette.green
                  .paint()
                  .color
                  .withOpacity(greenInitialOpacity),
            _PaintTypes.paint3: BasicPalette.blue.paint()
              ..color = BasicPalette.blue
                  .paint()
                  .color
                  .withOpacity(blueInitialOpacity),
          },
        );
        await game.ensureAdd(component);

        await component.add(
          OpacityEffect.to(
            targetOpacity,
            EffectController(duration: 1),
            target: component.opacityProviderOfList(),
          ),
        );

        game.update(1);

        expectDouble(
          component.getPaint(_PaintTypes.paint1).color.opacity,
          redInitialOpacity * targetOpacity,
        );
        expectDouble(
          component.getPaint(_PaintTypes.paint2).color.opacity,
          greenInitialOpacity * targetOpacity,
        );
        expectDouble(
          component.getPaint(_PaintTypes.paint3).color.opacity,
          blueInitialOpacity * targetOpacity,
        );
      },
    );

    testWithFlameGame(
      'maintains opacity ratios while ignoring some paints',
      (game) async {
        const redInitialOpacity = 0.9;
        const greenInitialOpacity = 0.5;
        const blueInitialOpacity = 0.2;
        const targetOpacity = 1.0;

        final component = _CustomPaintComponent<_PaintTypes>(
          {
            _PaintTypes.paint1: BasicPalette.red.paint()
              ..color = BasicPalette.green
                  .paint()
                  .color
                  .withOpacity(redInitialOpacity),
            _PaintTypes.paint2: BasicPalette.green.paint()
              ..color = BasicPalette.green
                  .paint()
                  .color
                  .withOpacity(greenInitialOpacity),
            _PaintTypes.paint3: BasicPalette.blue.paint()
              ..color = BasicPalette.blue
                  .paint()
                  .color
                  .withOpacity(blueInitialOpacity),
          },
        );
        await game.ensureAdd(component);

        await component.add(
          OpacityEffect.fadeIn(
            EffectController(duration: 1),
            target: component.opacityProviderOfList(
              paintIds: const [_PaintTypes.paint1, _PaintTypes.paint2],
            ),
          ),
        );

        game.update(1);

        expectDouble(
          component.getPaint(_PaintTypes.paint1).color.opacity,
          targetOpacity,
        );
        expectDouble(
          component.getPaint(_PaintTypes.paint2).color.opacity,
          (greenInitialOpacity / redInitialOpacity) * targetOpacity,
        );

        // Opacity of this paint shouldn't be changed.
        expectDouble(
          component.getPaint(_PaintTypes.paint3).color.opacity,
          blueInitialOpacity,
        );
      },
    );

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
      expectDouble(component.getOpacity(), 1.0, epsilon: _epsilon);
    });
  });
}
