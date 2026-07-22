import 'dart:math';

import 'package:flame/particles.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParticleCurve', () {
    test('interpolates linearly between from and to', () {
      final curve = ParticleCurve(2, 4);
      expect(curve.transform(0), 2);
      expect(curve.transform(0.5), closeTo(3, 1e-6));
      expect(curve.transform(1), 4);
    });

    test('applies an animation curve', () {
      final linear = ParticleCurve(0, 1);
      final eased = ParticleCurve(0, 1, curve: Curves.easeIn);
      expect(eased.transform(0), closeTo(0, 1e-6));
      expect(eased.transform(1), closeTo(1, 1e-6));
      expect(eased.transform(0.5), lessThan(linear.transform(0.5)));
    });

    test('constant keeps the same value', () {
      final curve = ParticleCurve.constant(7);
      expect(curve.transform(0), 7);
      expect(curve.transform(0.3), 7);
      expect(curve.transform(1), 7);
    });

    test('custom bakes an arbitrary function', () {
      final curve = ParticleCurve.custom((t) => sin(t * pi));
      expect(curve.transform(0), closeTo(0, 1e-3));
      expect(curve.transform(0.5), closeTo(1, 1e-3));
      expect(curve.transform(1), closeTo(0, 1e-3));
    });

    test('clamps the input to the unit interval', () {
      final curve = ParticleCurve(1, 2);
      expect(curve.transform(-1), 1);
      expect(curve.transform(2), 2);
    });
  });

  group('ParticleRange', () {
    test('samples uniformly within the range', () {
      final random = Random(42);
      const range = (2.0, 5.0);
      for (var i = 0; i < 100; i++) {
        final value = range.sample(random);
        expect(value, greaterThanOrEqualTo(2));
        expect(value, lessThan(5));
      }
    });

    test('a degenerate range is a constant', () {
      final random = Random(1);
      const range = (3.0, 3.0);
      expect(range.sample(random), 3);
    });
  });
}
