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
      expect(ec.progress, isNot(equals(0)));
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
        0.0734333516348943,
        0.06784203703768521,
        0.060923283194411315,
        0.05202093691489379,
        0.04032939038279296,
        0.02500062595136621,
        0.011900109469461025,
        0.005054520292697595,
        0.001797664482472573,
        0.00044657726207562496,
        0.0000015006292153437839,
      ]);
    });

    test('errors', () {
      expect(
        () => NoiseEffectController(duration: -1),
        failsAssert('Duration cannot be negative: -1.0'),
      );
    });

    // Regression test: high integer frequencies (like 400) used to produce
    // near-zero values on some platforms (e.g. Firefox) because the noise was
    // sampled at y=1, which when multiplied by an integer frequency landed on
    // an integer lattice point where Perlin noise returns 0.
    test('non-zero progress with high integer frequency', () {
      final ec = NoiseEffectController(
        duration: 0.2,
        noise: PerlinNoise(frequency: 400),
      );
      // Advance a small amount so timer > 0, then verify progress is non-zero
      ec.advance(0.016); // ~1 frame at 60fps
      expect(ec.progress, isNot(equals(0)));
      expect(ec.progress.abs(), greaterThan(0.001));
    });
  });
}
