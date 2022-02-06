import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/animation.dart';
import 'package:test/test.dart';

void main() {
  group('NoiseEffectController', () {
    test('general properties', () {
      final ec = NoiseEffectController(duration: 1, frequency: 12);
      expect(ec.duration, 1.0);
      expect(ec.frequency, 12.0);
      expect(ec.taperingCurve, Curves.easeInOutCubic);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);
      expect(ec.isRandom, false);
    });

    test('progression', () {
      final random = Random(567890);
      final ec = NoiseEffectController(
        duration: 1,
        frequency: 3,
        random: random,
      );
      final observed = <double>[];
      for (var t = 0.0; t < 1.0; t += 0.1) {
        observed.add(ec.progress);
        ec.advance(0.1);
      }
      expect(observed, [
        0.0,
        -0.4852269950897251,
        0.7905631204866628,
        0.25384428741054194,
        0.06718741964100555,
        0.08011164287850409,
        -0.008746065536907871,
        -0.07181264736289301,
        -0.014005001721806985,
        0.00985567863632108,
        -0.000015661267181374608,
      ]);
    });

    test('errors', () {
      expect(
        () => NoiseEffectController(duration: 0, frequency: 1),
        failsAssert('duration must be positive'),
      );
      expect(
        () => NoiseEffectController(duration: 1, frequency: 0),
        failsAssert('frequency parameter must be positive'),
      );
    });
  });
}
