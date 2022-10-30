import 'package:flame/src/effects/controllers/delayed_effect_controller.dart';
import 'package:flame/src/effects/controllers/linear_effect_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DelayedEffectController', () {
    test('normal', () {
      final ec = DelayedEffectController(LinearEffectController(1), delay: 3);
      expect(ec.isInfinite, false);
      expect(ec.isRandom, false);
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.progress, 0);
      expect(ec.duration, 4);

      for (var i = 0; i < 6; i++) {
        expect(ec.advance(0.5), 0);
        expect(ec.started, i == 5);
        expect(ec.progress, 0);
      }
      expect(ec.advance(1), 0);
      expect(ec.progress, 1);
      expect(ec.completed, true);
      expect(ec.advance(1), 1);
    });

    test('reset', () {
      final ec = DelayedEffectController(LinearEffectController(1), delay: 3);
      ec.setToEnd();
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);
      ec.setToStart();
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.progress, 0);
    });

    test('advance/recede', () {
      final ec = DelayedEffectController(LinearEffectController(1), delay: 3);

      expect(ec.advance(1), 0);
      expect(ec.recede(0.5), 0);
      expect(ec.advance(0.5), 0);
      expect(ec.advance(2), 0); // 3/3 + 0/1
      expect(ec.progress, 0);
      expect(ec.started, true);
      expect(ec.recede(0.5), 0); // 2.5/3 + 0/1
      expect(ec.started, false);
      expect(ec.advance(1), 0); // 3/3 + 0.5/1
      expect(ec.started, true);
      expect(ec.progress, closeTo(0.5, 1e-15));
      expect(ec.advance(1), closeTo(0.5, 1e-15)); // 3/3 + 1/1
      expect(ec.completed, true);
      expect(ec.recede(0.5), 0); // 3/3 + 0.5/1
      expect(ec.completed, false);
      expect(ec.started, true);
      expect(ec.progress, closeTo(0.5, 1e-15));
      expect(ec.recede(1), 0); // 2.5/3 + 0/1
      expect(ec.progress, 0);
      expect(ec.started, false);
      expect(ec.recede(3), closeTo(0.5, 1e-15));
    });

    test('errors', () {
      expect(
        () => DelayedEffectController(LinearEffectController(1), delay: -1),
        failsAssert('Delay must be non-negative: -1.0'),
      );
    });
  });
}
