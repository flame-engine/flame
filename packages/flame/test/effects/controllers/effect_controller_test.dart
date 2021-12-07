import 'dart:math';

import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EffectController', () {
    test('forward', () {
      final ec = EffectController(duration: 1.0);
      expect(ec.isInfinite, false);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0.0);

      ec.advance(0.5);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0.5);

      ec.advance(0.5);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1.0);

      // Updating controller after it already finished is a no-op
      ec.advance(0.5);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1.0);
    });

    test('forward x 2', () {
      final ec = EffectController(duration: 1, repeatCount: 2);
      expect(ec.started, true);
      expect(ec.progress, 0);

      ec.advance(1);
      expect(ec.progress, 1);
      ec.advance(1e-10);
      expect(ec.progress, closeTo(1e-10, 1e-15));
      ec.advance(1);
      expect(ec.progress, 1);
      expect(ec.completed, true);
    });

    test('forward + delay', () {
      final ec = EffectController(duration: 1.0, startDelay: 0.2);
      expect(ec.isInfinite, false);

      // initial delay
      for (var i = 0; i < 20; i++) {
        expect(ec.started, false);
        expect(ec.completed, false);
        expect(ec.progress, 0);
        ec.advance(0.01);
      }
      expect(ec.progress, closeTo(0, 1e-10));

      // progress from 0 to 1 over 1s
      for (var i = 0; i < 100; i++) {
        ec.advance(0.01);
        expect(ec.started, true);
        expect(ec.progress, closeTo((i + 1) / 100, 1e-10));
      }

      // final update, to account for any rounding errors
      ec.advance(1e-10);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('forward + atMax', () {
      final ec = EffectController(duration: 1, atMaxDuration: 0.5);
      expect(ec.duration, 1.5);
      expect(ec.isInfinite, false);
      expect(ec.progress, 0);

      ec.advance(1.5);
      expect(ec.progress, 1);
      expect(ec.started, true);
      expect(ec.completed, true);
    });

    test('(forward + reverse) x 5', () {
      final ec = EffectController(
        startDelay: 1.0,
        duration: 2.0,
        reverseDuration: 1.0,
        atMaxDuration: 0.2,
        atMinDuration: 0.5,
        repeatCount: 5,
      );
      expect(ec.isInfinite, false);
      expect(ec.progress, 0);
      expect(ec.started, false);
      expect(ec.completed, false);

      // Initial delay
      ec.advance(1.0);
      expect(ec.started, true);
      expect(ec.progress, 0);

      // 5 iterations
      for (var iteration = 0; iteration < 5; iteration++) {
        // forward
        for (var i = 0; i < 200; i++) {
          ec.advance(0.01);
          expect(ec.progress, closeTo((i + 1) / 200, 1e-10));
        }
        // atPeak
        for (var i = 0; i < 20; i++) {
          ec.advance(0.01);
          expect(ec.progress, closeTo(1, i == 19 ? 1e-10 : 0));
        }
        // reverse
        for (var i = 0; i < 100; i++) {
          ec.advance(0.01);
          expect(ec.progress, closeTo((99 - i) / 100, 1e-10));
        }
        // atPit
        for (var i = 0; i < 50; i++) {
          ec.advance(0.01);
          expect(ec.progress, closeTo(0, i == 49 ? 1e-10 : 0));
        }
      }

      // In the end, the progress will remain at zero
      ec.advance(1e-10);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 0);
    });

    testRandom('infinite', (Random random) {
      const duration = 1.4;
      final ec = EffectController(duration: duration, infinite: true);
      expect(ec.isInfinite, true);
      expect(ec.progress, 0);
      expect(ec.started, true);
      expect(ec.completed, false);

      var stageTime = 0.0;
      for (var i = 0; i < 100; i++) {
        final dt = random.nextDouble() * 0.3;
        ec.advance(dt);
        stageTime += dt;
        if (stageTime >= duration) {
          stageTime -= duration;
        }
        expect(ec.progress, closeTo(stageTime / duration, 1e-10));
      }

      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.isInfinite, true);
    });

    test('reset', () {
      final ec = EffectController(duration: 1.23);
      expect(ec.started, true);
      expect(ec.progress, 0);

      ec.advance(0.4);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, closeTo(0.4 / 1.23, 1e-10));

      ec.setToStart();
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);

      ec.advance(0.5);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, closeTo(0.5 / 1.23, 1e-10));

      ec.advance(1);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);

      ec.setToStart();
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);
    });

    test('errors', () {
      void expectThrows(void Function() func) {
        expect(func, throwsA(isA<AssertionError>()));
      }

      expectThrows(
        () => EffectController(duration: -1),
      );
      expectThrows(
        () => EffectController(duration: 1, repeatCount: 0),
      );
      expectThrows(
        () => EffectController(
          duration: 1,
          infinite: true,
          repeatCount: 3,
        ),
      );
      expectThrows(
        () => EffectController(duration: 1, repeatCount: -1),
      );
      expectThrows(
        () => EffectController(duration: 1, reverseDuration: -1),
      );
      expectThrows(
        () => EffectController(duration: 1, startDelay: -1),
      );
      expectThrows(
        () => EffectController(duration: 1, atMaxDuration: -1),
      );
      expectThrows(
        () => EffectController(duration: 1, atMinDuration: -1),
      );
    });

    test('curve', () {
      const curve = Curves.easeIn;
      final ec = EffectController(
        duration: 1,
        curve: curve,
        reverseDuration: 0.8,
      );
      expect(ec.started, true);
      expect(ec.duration, 1.8);

      for (var i = 0; i < 100; i++) {
        ec.advance(0.01);
        // Precision is less for final iteration, because it may flip over
        // to the backwards curve.
        final epsilon = i == 99 ? 1e-6 : 1e-10;
        expect(ec.progress, closeTo(curve.transform((i + 1) / 100), epsilon));
      }
      for (var i = 0; i < 80; i++) {
        ec.advance(0.01);
        expect(
          ec.progress,
          closeTo(curve.flipped.transform(1 - (i + 1) / 80), 1e-10),
        );
      }
      ec.advance(1e-10);
      expect(ec.completed, true);
      expect(ec.progress, 0);
    });

    test('reverse curve', () {
      const curve = Curves.easeInQuad;
      final ec = EffectController(
        duration: 1,
        reverseDuration: 1,
        reverseCurve: curve,
      );
      expect(ec.started, true);
      expect(ec.duration, 2);

      ec.advance(1);
      expect(ec.progress, 1);
      expect(ec.completed, false);

      for (var i = 0; i < 100; i++) {
        ec.advance(0.01);
        expect(ec.progress, closeTo(curve.transform(1 - (i + 1) / 100), 1e-10));
      }
      ec.advance(1e-10);
      expect(ec.completed, true);
    });
  });
}
