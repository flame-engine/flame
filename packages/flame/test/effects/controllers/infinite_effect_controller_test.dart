import 'dart:math';

import 'package:flame/src/effects/controllers/infinite_effect_controller.dart';
import 'package:flame/src/effects/controllers/linear_effect_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InfiniteEffectController', () {
    test('basic properties', () {
      final ec = InfiniteEffectController(LinearEffectController(1));
      expect(ec.isInfinite, true);
      expect(ec.isRandom, false);
      expect(ec.duration, double.infinity);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);
    });

    test('reset', () {
      final ec = InfiniteEffectController(LinearEffectController(1));
      ec.setToEnd();
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 1);
      ec.setToStart();
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);
    });

    testRandom('advance', (Random random) {
      final ec = InfiniteEffectController(LinearEffectController(1));
      var totalTime = 0.0;
      while (totalTime < 10) {
        final dt = random.nextDouble() * 0.1;
        totalTime += dt;
        expect(ec.advance(dt), 0);
        expect(ec.progress, closeTo(totalTime % 1, 5e-14));
      }
      expect(ec.completed, false);
    });

    testRandom('recede', (Random random) {
      final ec = InfiniteEffectController(LinearEffectController(1));
      var totalTime = 0.0;
      while (totalTime < 10) {
        final dt = random.nextDouble() * 0.1;
        totalTime += dt;
        expect(ec.recede(dt), 0);
        expect(ec.progress, closeTo((11 - totalTime) % 1, 5e-14));
      }
      expect(ec.completed, false);
    });
  });
}
