import 'package:fast_noise/fast_noise.dart';
import 'package:flame_noise/flame_noise.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/animation.dart';
import 'package:test/test.dart';

void main() {
  group('PerlinNoiseEffectController', () {
    test('general properties', () {
      final ec = NoiseEffectController(
        duration: 1,
        noise: PerlinNoise(frequency: 12),
      );
      expect(ec.duration, 1.0);
      expect(ec.taperingCurve, Curves.easeInOutCubic);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);
      expect(ec.isRandom, false);
    });

    test('progression', () {
      final ec = NoiseEffectController(
        duration: 1,
        noise: PerlinNoise(frequency: 0.05),
      );
      final observed = <double>[];
      for (var t = 0.0; t < 1.0; t += 0.1) {
        observed.add(ec.progress);
        ec.advance(0.1);
      }
      expect(observed, [
        0.051042312500000006,
        0.04563924284681871,
        0.03940642509655703,
        0.03206554217595054,
        0.02339568569800122,
        0.013401536786893568,
        0.005727844335713328,
        0.002079860116340368,
        0.000573751223192571,
        0.00008544214797850498,
        3.6806334242205264e-9,
      ]);
    });

    test('errors', () {
      expect(
        () => NoiseEffectController(duration: -1),
        failsAssert('Duration cannot be negative: -1.0'),
      );
    });
  });
}
