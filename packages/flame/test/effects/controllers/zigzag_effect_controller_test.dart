import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZigzagEffectController', () {
    test('general properties', () {
      final ec = ZigzagEffectController(period: 1);
      expect(ec.duration, 1);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);
      expect(ec.isRandom, false);
    });

    test('progression', () {
      final ec = ZigzagEffectController(period: 4);
      final expectedProgress = [
        for (var i = 0; i < 10; i++) i * 0.1,
        for (var i = 10; i > 0; i--) i * 0.1,
        for (var i = 0; i > -10; i--) i * 0.1,
        for (var i = -10; i <= 0; i++) i * 0.1,
      ];
      for (final p in expectedProgress) {
        expect(ec.progress, closeTo(p, 3e-15));
        ec.advance(0.1);
      }
      expect(ec.completed, true);
    });

    test('errors', () {
      expect(
        () => ZigzagEffectController(period: 0),
        failsAssert('Period must be positive: 0.0'),
      );
      expect(
        () => ZigzagEffectController(period: -1.1),
        failsAssert('Period must be positive: -1.1'),
      );
    });
  });
}
