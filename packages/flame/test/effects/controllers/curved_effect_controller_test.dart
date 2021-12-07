import 'dart:math';

import 'package:flame/src/effects/controllers/curved_effect_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurvedEffectController', () {
    const curves = <Curve>[
      Curves.bounceIn,
      Curves.bounceInOut,
      Curves.bounceOut,
      Curves.decelerate,
      Curves.ease,
      Curves.easeIn,
      Curves.easeInBack,
      Curves.easeInCirc,
      Curves.easeInCubic,
      Curves.easeInExpo,
      Curves.easeInOut,
      Curves.easeInOutBack,
      Curves.easeInOutCirc,
      Curves.easeInOutCubic,
      Curves.easeInOutCubicEmphasized,
      Curves.easeInOutExpo,
      Curves.easeInOutQuad,
      Curves.easeInOutQuart,
      Curves.easeInOutQuint,
      Curves.easeInOutSine,
      Curves.easeInQuad,
      Curves.easeInQuart,
      Curves.easeInQuint,
      Curves.easeInSine,
      Curves.easeInToLinear,
      Curves.easeOut,
      Curves.easeOutBack,
      Curves.easeOutCirc,
      Curves.easeOutCubic,
      Curves.easeOutExpo,
      Curves.easeOutQuad,
      Curves.easeOutQuart,
      Curves.easeOutQuint,
      Curves.easeOutSine,
      Curves.elasticIn,
      Curves.elasticInOut,
      Curves.elasticOut,
      Curves.fastLinearToSlowEaseIn,
      Curves.fastOutSlowIn,
      Curves.linear,
      Curves.linearToEaseOut,
      Curves.slowMiddle,
    ];

    testRandom('normal', (Random random) {
      final duration = random.nextDouble();
      final curve = curves[random.nextInt(curves.length)];
      final ec = CurvedEffectController(duration, curve);

      expect(ec.progress, 0);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.curve, curve);
      expect(ec.isInfinite, false);
      expect(ec.isRandom, false);
      expect(ec.duration, duration);

      var totalTime = 0.0;
      while (totalTime < duration) {
        final dt = random.nextDouble() * 0.01;
        totalTime += dt;
        final leftoverTime = ec.advance(dt);
        if (totalTime > duration) {
          expect(leftoverTime, closeTo(totalTime - duration, 1e-15));
          expect(ec.progress, 1);
        } else {
          expect(leftoverTime, 0);
          expect(
            ec.progress,
            closeTo(curve.transform(totalTime / duration), 1e-15),
          );
        }
      }
      expect(ec.progress, 1);
      expect(ec.completed, true);

      totalTime = duration;
      while (totalTime > 0) {
        final dt = random.nextDouble() * 0.01;
        totalTime -= dt;
        final leftoverTime = ec.recede(dt);
        if (totalTime > 0) {
          expect(leftoverTime, 0);
          expect(
            ec.progress,
            closeTo(curve.transform(totalTime / duration), 1e-15),
          );
        } else {
          expect(leftoverTime, closeTo(-totalTime, 1e-15));
          expect(ec.progress, 0);
        }
      }
      expect(ec.progress, 0);
      expect(ec.completed, false);
    });

    test('errors', () {
      expect(
        () => CurvedEffectController(0, Curves.linear),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => CurvedEffectController(-1, Curves.linear),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
