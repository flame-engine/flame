import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SineEffectController', () {
    test('general properties', () {
      final ec = SineEffectController(period: 1);
      expect(ec.duration, 1);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);
      expect(ec.isRandom, false);
    });

    test('progression', () {
      final ec = SineEffectController(period: 3);
      final expectedProgress =
          List<double>.generate(101, (i) => sin(i * 0.01 * 2 * pi));
      for (final p in expectedProgress) {
        expect(ec.progress, closeTo(p, 2e-14));
        ec.advance(0.01 * 3);
      }
      expect(ec.completed, true);
    });

    test('errors', () {
      expect(
        () => SineEffectController(period: 0),
        failsAssert('Period must be positive: 0.0'),
      );
      expect(
        () => SineEffectController(period: -1.1),
        failsAssert('Period must be positive: -1.1'),
      );
    });
  });
}
