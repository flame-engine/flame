import 'dart:math';

import 'package:flame/src/effects2/standard_animation_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StandardAnimationController', () {
    test('forward', () {
      final ac = StandardAnimationController(duration: 1.0);
      expect(ac.isInfinite, false);
      expect(ac.isSimpleAnimation, true);
      expect(ac.started, false);
      expect(ac.completed, false);
      expect(ac.progress, 0.0);

      ac.update(0.5);
      expect(ac.started, true);
      expect(ac.completed, false);
      expect(ac.progress, 0.5);

      ac.update(0.5);
      expect(ac.started, true);
      expect(ac.completed, true);
      expect(ac.progress, 1.0);

      // Updating controller after it already finished is a no-op
      ac.update(0.5);
      expect(ac.started, true);
      expect(ac.completed, true);
      expect(ac.progress, 1.0);
    });

    test('forward x 2', () {
      final ac = StandardAnimationController(duration: 1, repeatCount: 2);
      expect(ac.isSimpleAnimation, true);
      expect(ac.started, false);
      expect(ac.progress, 0);

      ac.update(1);
      expect(ac.progress, 1);
      ac.update(0);
      expect(ac.progress, 0);
      ac.update(1);
      expect(ac.progress, 1);
      expect(ac.completed, true);
    });

    test('forward + delay', () {
      final ac = StandardAnimationController(duration: 1.0, startDelay: 0.2);
      expect(ac.isInfinite, false);
      expect(ac.isSimpleAnimation, true);

      // initial delay
      for (var i = 0; i < 20; i++) {
        expect(ac.started, false);
        expect(ac.completed, false);
        expect(ac.progress, 0);
        ac.update(0.01);
      }
      expect(ac.progress, closeTo(0, 1e-10));

      // progress from 0 to 1 over 1s
      for (var i = 0; i < 100; i++) {
        ac.update(0.01);
        expect(ac.started, true);
        expect(ac.progress, closeTo((i + 1) / 100, 1e-10));
      }

      // final update, to account for any rounding errors
      ac.update(1e-10);
      expect(ac.completed, true);
      expect(ac.progress, 1);
    });

    test('forward + atPeak', () {
      final ac = StandardAnimationController(duration: 1, atMaxDuration: 0.5);
      expect(ac.cycleDuration, 1.5);
      expect(ac.isSimpleAnimation, false);
      expect(ac.isInfinite, false);
      expect(ac.progress, 0);

      ac.update(1.5);
      expect(ac.progress, 1);
      expect(ac.started, true);
      expect(ac.completed, false);
      ac.update(0);
      expect(ac.progress, 1);
      expect(ac.completed, true);
    });

    test('(forward + reverse) x 5', () {
      final ac = StandardAnimationController(
        startDelay: 1.0,
        duration: 2.0,
        reverseDuration: 1.0,
        atMaxDuration: 0.2,
        atMinDuration: 0.5,
        repeatCount: 5,
      );
      expect(ac.isInfinite, false);
      expect(ac.progress, 0);
      expect(ac.repeatCount, 5);
      expect(ac.started, false);
      expect(ac.completed, false);
      expect(ac.forwardDuration, 2.0);
      expect(ac.backwardDuration, 1.0);
      expect(ac.atMaxDuration, 0.2);
      expect(ac.atMinDuration, 0.5);
      expect(ac.cycleDuration, 3.7);
      expect(ac.isSimpleAnimation, false);

      // Initial delay
      ac.update(1.0);
      expect(ac.started, true);
      expect(ac.progress, 0);

      // 5 iterations
      for (var iteration = 0; iteration < 5; iteration++) {
        // forward
        for (var i = 0; i < 200; i++) {
          ac.update(0.01);
          expect(ac.progress, closeTo((i + 1) / 200, 1e-10));
        }
        // atPeak
        for (var i = 0; i < 20; i++) {
          ac.update(0.01);
          expect(ac.progress, closeTo(1, i == 19 ? 1e-10 : 0));
        }
        // reverse
        for (var i = 0; i < 100; i++) {
          ac.update(0.01);
          expect(ac.progress, closeTo((99 - i) / 100, 1e-10));
        }
        // atPit
        for (var i = 0; i < 50; i++) {
          ac.update(0.01);
          expect(ac.progress, closeTo(0, i == 49 ? 1e-10 : 0));
        }
      }

      // In the end, the progress will remain at zero
      ac.update(1e-10);
      expect(ac.started, true);
      expect(ac.completed, true);
      expect(ac.progress, 0);
    });

    testRandom('infinite', (Random random) {
      final ac = StandardAnimationController(duration: 1.4, infinite: true);
      expect(ac.isInfinite, true);
      expect(ac.isSimpleAnimation, true);
      expect(ac.progress, 0);
      expect(ac.started, false);

      ac.update(0);
      expect(ac.started, true);
      expect(ac.completed, false);
      expect(ac.progress, 0);

      var stageTime = 0.0;
      for (var i = 0; i < 100; i++) {
        final dt = random.nextDouble() * 0.3;
        ac.update(dt);
        stageTime += dt;
        if (stageTime >= ac.forwardDuration) {
          stageTime -= ac.forwardDuration;
          // The controller will report once `progress==1`, exactly, and then
          // once `progress==0`, also exactly.
          expect(ac.progress, 1);
          ac.update(0);
          expect(ac.progress, 0);
        } else {
          expect(ac.progress, closeTo(stageTime / ac.forwardDuration, 1e-10));
        }
      }

      expect(ac.started, true);
      expect(ac.completed, false);
      expect(ac.isInfinite, true);
    });

    test('reset', () {
      final ac = StandardAnimationController(duration: 1.23);
      expect(ac.started, false);
      expect(ac.progress, 0);

      ac.update(0.4);
      expect(ac.started, true);
      expect(ac.completed, false);
      expect(ac.progress, closeTo(0.4 / 1.23, 1e-10));

      ac.reset();
      expect(ac.started, false);
      expect(ac.completed, false);
      expect(ac.progress, 0);

      ac.update(0.5);
      expect(ac.started, true);
      expect(ac.completed, false);
      expect(ac.progress, closeTo(0.5 / 1.23, 1e-10));

      ac.update(1);
      expect(ac.started, true);
      expect(ac.completed, true);
      expect(ac.progress, 1);

      ac.reset();
      expect(ac.started, false);
      expect(ac.completed, false);
      expect(ac.progress, 0);
    });

    test('errors', () {
      void expectThrows(void Function() func) {
        expect(func, throwsA(isA<AssertionError>()));
      }

      expectThrows(
        () => StandardAnimationController(duration: -1),
      );
      expectThrows(
        () => StandardAnimationController(duration: 1, repeatCount: 0),
      );
      expectThrows(
        () => StandardAnimationController(
            duration: 1, infinite: true, repeatCount: 3),
      );
      expectThrows(
        () => StandardAnimationController(duration: 1, repeatCount: -1),
      );
      expectThrows(
        () => StandardAnimationController(duration: 1, reverseDuration: -1),
      );
      expectThrows(
        () => StandardAnimationController(duration: 1, startDelay: -1),
      );
      expectThrows(
        () => StandardAnimationController(duration: 1, atMaxDuration: -1),
      );
      expectThrows(
        () => StandardAnimationController(duration: 1, atMinDuration: -1),
      );
    });

    test('curve', () {
      final curve = Curves.easeIn;
      final ac = StandardAnimationController(
        duration: 1,
        curve: curve,
        reverseDuration: 0.8,
      );
      expect(ac.started, false);
      expect(ac.cycleDuration, 1.8);

      for (var i = 0; i < 100; i++) {
        ac.update(0.01);
        expect(ac.progress, closeTo(curve.transform((i + 1) / 100), 1e-10));
      }
      for (var i = 0; i < 80; i++) {
        ac.update(0.01);
        expect(ac.progress,
            closeTo(curve.flipped.transform(1 - (i + 1) / 80), 1e-10));
      }
      ac.update(1e-10);
      expect(ac.completed, true);
      expect(ac.progress, 0);
    });

    test('reverse curve', () {
      final curve = Curves.easeInQuad;
      final ac = StandardAnimationController(
        duration: 1,
        reverseDuration: 1,
        reverseCurve: curve,
      );
      expect(ac.started, false);
      expect(ac.cycleDuration, 2);

      ac.update(1);
      expect(ac.progress, 1);
      expect(ac.completed, false);

      for (var i = 0; i < 100; i++) {
        ac.update(0.01);
        expect(ac.progress, closeTo(curve.transform(1 - (i + 1) / 100), 1e-10));
      }
      ac.update(1e-10);
      expect(ac.completed, true);
    });
  });
}
