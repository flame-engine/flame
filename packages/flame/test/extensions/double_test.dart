import 'dart:math';

import 'package:flame/src/extensions/double.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleExtension', () {
    group('toFinite', () {
      test('Properly converts infinite values to maxFinite', () {
        const infinity = double.infinity;
        expect(infinity.toFinite(), double.maxFinite);
        const negativeInfinity = -double.infinity;
        expect(negativeInfinity.toFinite(), -double.maxFinite);
      });

      test('Does not convert already finite value', () {
        expect(0.0.toFinite(), 0.0);
        expect(double.maxFinite.toFinite(), double.maxFinite);
        expect((-double.maxFinite).toFinite(), -double.maxFinite);
      });
    });

    group('normalizedAngle', () {
      test('Does not convert value within [-pi, pi] range', () {
        expect((pi / 2).toNormalizedAngle(), pi / 2);
      });

      test('Converts value greater than pi to normalized angle', () {
        expect((3 * pi / 2).toNormalizedAngle(), -pi / 2);
      });

      test('Converts value less than -pi to normalized angle', () {
        expect((-3 * pi / 2).toNormalizedAngle(), pi / 2);
      });

      test('Converts value equal to 2pi to normalized angle', () {
        expect((2 * pi).toNormalizedAngle(), 0.0);
      });

      test('Converts value equal to -2pi to normalized angle', () {
        expect((-2 * pi).toNormalizedAngle(), 0.0);
      });

      test('Does not convert value equal to pi', () {
        expect(pi.toNormalizedAngle(), pi);
      });

      test('Does not convert value equal to -pi', () {
        expect((-pi).toNormalizedAngle(), -pi);
      });
    });
  });
}
