import 'dart:math' as math;

import 'package:flame_test/src/epsilon.dart';
import 'package:test/test.dart';

void main() {
  group('Float32 epsilon tests', () {
    test('getNextFloat32 should return a slightly larger value', () {
      const original = 1.0;
      final next = nextFloat32(original);

      expect(next, greaterThan(original));
      expect(
        next - original,
        closeTo(1.1920928955078125e-7, 1e-7),
      ); // Expected epsilon for 1.0
    });

    test('getPrevFloat32 should return a slightly smaller value', () {
      const original = 1.0;
      final prev = prevFloat32(original);

      expect(prev, lessThan(original));
      expect(
        original - prev,
        closeTo(1.1920928955078125e-7, 1e-7),
      ); // Expected epsilon for 1.0
    });

    test('next > original > prev for positive values', () {
      final testValues = [0.5, 1.0, 2.0, 10.0, 100.0, 1000.0];

      for (final value in testValues) {
        final next = nextFloat32(value);
        final prev = prevFloat32(value);

        expect(
          next,
          greaterThan(value),
          reason: 'Next value should be greater than $value',
        );
        expect(
          prev,
          lessThan(value),
          reason: 'Previous value should be less than $value',
        );
        expect(
          next,
          greaterThan(prev),
          reason: 'Next should be greater than previous for $value',
        );
      }
    });

    test('next > original > prev for negative values', () {
      final testValues = [-0.5, -1.0, -2.0, -10.0, -100.0, -1000.0];

      for (final value in testValues) {
        final next = nextFloat32(value);
        final prev = prevFloat32(value);

        expect(
          next,
          greaterThan(value),
          reason: 'Next value should be greater than $value',
        );
        expect(
          prev,
          lessThan(value),
          reason: 'Previous value should be less than $value',
        );
      }
    });

    test('epsilon scales with value magnitude', () {
      // Test with powers of 10.
      for (var i = 0; i <= 5; i++) {
        final value = math.pow(10, i).toDouble();
        final next = nextFloat32(value);
        final epsilon = next - value;

        // The ratio of epsilon to value should be roughly constant.
        final relativeEpsilon = epsilon / value;
        expect(
          relativeEpsilon,
          closeTo(1.1920928955078125e-7, 1e-7),
          reason: 'Relative epsilon should be consistent for value $value',
        );
      }
    });

    test('when value is zero', () {
      const zero = 0.0;
      final nextAfterZero = nextFloat32(zero);
      final prevBeforeZero = prevFloat32(zero);

      expect(nextAfterZero, greaterThan(zero));
      expect(prevBeforeZero, lessThan(zero));

      // The smallest positive float32 is approximately 1.4e-45
      expect(nextAfterZero, closeTo(1.401298464324817e-45, 1e-45));
      expect(prevBeforeZero, closeTo(-1.401298464324817e-45, 1e-45));
    });

    test('when value is near infinity', () {
      // Float32 max is approximately 3.4028235e+38
      const largeValue = 3.4028234e+38;
      final next = nextFloat32(largeValue);
      final prev = prevFloat32(largeValue);

      expect(next, greaterThan(largeValue));
      expect(prev, lessThan(largeValue));
      expect(
        next.isFinite,
        isFalse,
        reason: 'Next value should be infinity for largeValue',
      );
    });

    test('next / prev should be ~ reversible', () {
      final testValues = [1.0, -1.0, 123.0, -42.0];

      for (final value in testValues) {
        final next = nextFloat32(value);
        final backToOriginal = prevFloat32(next);

        // Small precision tolerance.
        expect(
          backToOriginal,
          closeTo(value, 1e-6),
          reason: 'getPrev(getNext(value)) should be close to value',
        );

        final prev = prevFloat32(value);
        final alsoBackToOriginal = nextFloat32(prev);

        expect(
          alsoBackToOriginal,
          closeTo(value, 1e-6),
          reason: 'getNext(getPrev(value)) should be close to value',
        );
      }
    });

    test('NaN stays NaN', () {
      const nan = double.nan;
      expect(nextFloat32(nan).isNaN, isTrue);
      expect(prevFloat32(nan).isNaN, isTrue);
    });

    test('infinite stays inf, next(-inf) and prev(inf) are finite', () {
      const posInf = double.infinity;
      const negInf = double.negativeInfinity;

      // Positive infinity should remain infinity when getting next
      expect(nextFloat32(posInf), equals(posInf));
      // Previous value before positive infinity should be finite
      expect(prevFloat32(posInf).isFinite, isTrue);

      // Next value after negative infinity should be finite
      expect(nextFloat32(negInf).isFinite, isTrue);
      // Negative infinity should remain infinity when getting previous
      expect(prevFloat32(negInf), equals(negInf));
    });
  });
}
