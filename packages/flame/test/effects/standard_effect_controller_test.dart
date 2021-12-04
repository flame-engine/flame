import 'dart:math';

import 'package:flame/src/effects2/standard_effect_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StandardEffectController', () {
    test('forward', () {
      final ec = StandardEffectController(duration: 1.0);
      expect(ec.isInfinite, false);
      expect(ec.isSimpleAnimation, true);
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.progress, 0.0);

      ec.update(0.5);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0.5);

      ec.update(0.5);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1.0);

      // Updating controller after it already finished is a no-op
      ec.update(0.5);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1.0);
    });

    test('forward x 2', () {
      final ec = StandardEffectController(duration: 1, repeatCount: 2);
      expect(ec.isSimpleAnimation, true);
      expect(ec.started, false);
      expect(ec.progress, 0);

      ec.update(1);
      expect(ec.progress, 1);
      ec.update(0);
      expect(ec.progress, 0);
      ec.update(1);
      expect(ec.progress, 1);
      expect(ec.completed, true);
    });

    test('forward + delay', () {
      final ec = StandardEffectController(duration: 1.0, startDelay: 0.2);
      expect(ec.isInfinite, false);
      expect(ec.isSimpleAnimation, true);

      // initial delay
      for (var i = 0; i < 20; i++) {
        expect(ec.started, false);
        expect(ec.completed, false);
        expect(ec.progress, 0);
        ec.update(0.01);
      }
      expect(ec.progress, closeTo(0, 1e-10));

      // progress from 0 to 1 over 1s
      for (var i = 0; i < 100; i++) {
        ec.update(0.01);
        expect(ec.started, true);
        expect(ec.progress, closeTo((i + 1) / 100, 1e-10));
      }

      // final update, to account for any rounding errors
      ec.update(1e-10);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('forward + atMax', () {
      final ec = StandardEffectController(duration: 1, atMaxDuration: 0.5);
      expect(ec.cycleDuration, 1.5);
      expect(ec.isSimpleAnimation, false);
      expect(ec.isInfinite, false);
      expect(ec.progress, 0);

      ec.update(1.5);
      expect(ec.progress, 1);
      expect(ec.started, true);
      expect(ec.completed, false);
      ec.update(0);
      expect(ec.progress, 1);
      expect(ec.completed, true);
    });

    test('(forward + reverse) x 5', () {
      final ec = StandardEffectController(
        startDelay: 1.0,
        duration: 2.0,
        reverseDuration: 1.0,
        atMaxDuration: 0.2,
        atMinDuration: 0.5,
        repeatCount: 5,
      );
      expect(ec.isInfinite, false);
      expect(ec.progress, 0);
      expect(ec.repeatCount, 5);
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.forwardDuration, 2.0);
      expect(ec.backwardDuration, 1.0);
      expect(ec.atMaxDuration, 0.2);
      expect(ec.atMinDuration, 0.5);
      expect(ec.cycleDuration, 3.7);
      expect(ec.isSimpleAnimation, false);

      // Initial delay
      ec.update(1.0);
      expect(ec.started, true);
      expect(ec.progress, 0);

      // 5 iterations
      for (var iteration = 0; iteration < 5; iteration++) {
        // forward
        for (var i = 0; i < 200; i++) {
          ec.update(0.01);
          expect(ec.progress, closeTo((i + 1) / 200, 1e-10));
        }
        // atPeak
        for (var i = 0; i < 20; i++) {
          ec.update(0.01);
          expect(ec.progress, closeTo(1, i == 19 ? 1e-10 : 0));
        }
        // reverse
        for (var i = 0; i < 100; i++) {
          ec.update(0.01);
          expect(ec.progress, closeTo((99 - i) / 100, 1e-10));
        }
        // atPit
        for (var i = 0; i < 50; i++) {
          ec.update(0.01);
          expect(ec.progress, closeTo(0, i == 49 ? 1e-10 : 0));
        }
      }

      // In the end, the progress will remain at zero
      ec.update(1e-10);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 0);
    });

    testRandom('infinite', (Random random) {
      final ec = StandardEffectController(duration: 1.4, infinite: true);
      expect(ec.isInfinite, true);
      expect(ec.isSimpleAnimation, true);
      expect(ec.progress, 0);
      expect(ec.started, false);

      ec.update(0);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);

      var stageTime = 0.0;
      for (var i = 0; i < 100; i++) {
        final dt = random.nextDouble() * 0.3;
        ec.update(dt);
        stageTime += dt;
        if (stageTime >= ec.forwardDuration) {
          stageTime -= ec.forwardDuration;
          // The controller will report once `progress==1`, exactly, and then
          // once `progress==0`, also exactly.
          expect(ec.progress, 1);
          ec.update(0);
          expect(ec.progress, 0);
        } else {
          expect(ec.progress, closeTo(stageTime / ec.forwardDuration, 1e-10));
        }
      }

      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.isInfinite, true);
    });

    test('reset', () {
      final ec = StandardEffectController(duration: 1.23);
      expect(ec.started, false);
      expect(ec.progress, 0);

      ec.update(0.4);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, closeTo(0.4 / 1.23, 1e-10));

      ec.reset();
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.progress, 0);

      ec.update(0.5);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, closeTo(0.5 / 1.23, 1e-10));

      ec.update(1);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);

      ec.reset();
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.progress, 0);
    });

    test('errors', () {
      void expectThrows(void Function() func) {
        expect(func, throwsA(isA<AssertionError>()));
      }

      expectThrows(
        () => StandardEffectController(duration: -1),
      );
      expectThrows(
        () => StandardEffectController(duration: 1, repeatCount: 0),
      );
      expectThrows(
        () => StandardEffectController(
          duration: 1,
          infinite: true,
          repeatCount: 3,
        ),
      );
      expectThrows(
        () => StandardEffectController(duration: 1, repeatCount: -1),
      );
      expectThrows(
        () => StandardEffectController(duration: 1, reverseDuration: -1),
      );
      expectThrows(
        () => StandardEffectController(duration: 1, startDelay: -1),
      );
      expectThrows(
        () => StandardEffectController(duration: 1, atMaxDuration: -1),
      );
      expectThrows(
        () => StandardEffectController(duration: 1, atMinDuration: -1),
      );
    });

    test('curve', () {
      final curve = Curves.easeIn;
      final ec = StandardEffectController(
        duration: 1,
        curve: curve,
        reverseDuration: 0.8,
      );
      expect(ec.started, false);
      expect(ec.cycleDuration, 1.8);

      for (var i = 0; i < 100; i++) {
        ec.update(0.01);
        expect(ec.progress, closeTo(curve.transform((i + 1) / 100), 1e-10));
      }
      for (var i = 0; i < 80; i++) {
        ec.update(0.01);
        expect(
          ec.progress,
          closeTo(curve.flipped.transform(1 - (i + 1) / 80), 1e-10),
        );
      }
      ec.update(1e-10);
      expect(ec.completed, true);
      expect(ec.progress, 0);
    });

    test('reverse curve', () {
      final curve = Curves.easeInQuad;
      final ec = StandardEffectController(
        duration: 1,
        reverseDuration: 1,
        reverseCurve: curve,
      );
      expect(ec.started, false);
      expect(ec.cycleDuration, 2);

      ec.update(1);
      expect(ec.progress, 1);
      expect(ec.completed, false);

      for (var i = 0; i < 100; i++) {
        ec.update(0.01);
        expect(ec.progress, closeTo(curve.transform(1 - (i + 1) / 100), 1e-10));
      }
      ec.update(1e-10);
      expect(ec.completed, true);
    });
  });
}
