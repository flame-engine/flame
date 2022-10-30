import 'package:flame/src/effects/controllers/infinite_effect_controller.dart';
import 'package:flame/src/effects/controllers/linear_effect_controller.dart';
import 'package:flame/src/effects/controllers/repeated_effect_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RepeatedEffectController', () {
    test('basic properties', () {
      final ec = RepeatedEffectController(LinearEffectController(1), 5);
      expect(ec.isInfinite, false);
      expect(ec.isRandom, false);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.duration, 5);
      expect(ec.progress, 0);
      expect(ec.repeatCount, 5);
      expect(ec.remainingIterationsCount, 5);
    });

    test('reset', () {
      final ec = RepeatedEffectController(LinearEffectController(1), 5);
      ec.setToEnd();
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.child.completed, true);
      expect(ec.progress, 1);
      expect(ec.remainingIterationsCount, 0);

      ec.setToStart();
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.child.completed, false);
      expect(ec.progress, 0);
      expect(ec.remainingIterationsCount, 5);
    });

    test('advance', () {
      final ec = RepeatedEffectController(LinearEffectController(2), 5);
      expect(ec.remainingIterationsCount, 5);

      // First iteration
      expect(ec.advance(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.remainingIterationsCount, 5);

      expect(ec.advance(1), 0);
      expect(ec.progress, 1);
      expect(ec.remainingIterationsCount, 5);

      // Second iteration
      expect(ec.advance(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.remainingIterationsCount, 4);

      expect(ec.advance(1), 0);
      expect(ec.progress, 1);
      expect(ec.remainingIterationsCount, 4);

      // Third iteration
      expect(ec.advance(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.remainingIterationsCount, 3);

      expect(ec.advance(1), 0);
      expect(ec.progress, 1);
      expect(ec.remainingIterationsCount, 3);

      // Forth iteration
      expect(ec.advance(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.remainingIterationsCount, 2);

      expect(ec.advance(1), 0);
      expect(ec.progress, 1);
      expect(ec.remainingIterationsCount, 2);

      // Fifth iteration
      expect(ec.advance(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.remainingIterationsCount, 1);

      expect(ec.advance(1), 0);
      expect(ec.progress, 1);
      // last iteration is consumed immediately
      expect(ec.remainingIterationsCount, 0);
      expect(ec.completed, true);

      // Any subsequent time will be spilled over
      expect(ec.advance(1), 1);
      expect(ec.progress, 1);
      expect(ec.completed, true);
    });

    test('advance 2', () {
      const n = 5;
      const dt = 0.17;
      final nIterations = (n / dt).floor();
      final ec = RepeatedEffectController(LinearEffectController(1), n);
      for (var i = 0; i < nIterations; i++) {
        expect(ec.advance(dt), 0);
        expect(ec.progress, closeTo((i + 1) * dt % 1, 1e-15));
      }
      expect(ec.advance(dt), closeTo((nIterations + 1) * dt - n, 1e-15));
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('recede', () {
      final ec = RepeatedEffectController(LinearEffectController(2), 5);
      ec.setToEnd();
      expect(ec.completed, true);
      expect(ec.recede(0), 0);
      expect(ec.completed, true);
      expect(ec.remainingIterationsCount, 0);

      // Fifth iteration
      expect(ec.recede(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.completed, false);
      expect(ec.remainingIterationsCount, 1);

      expect(ec.recede(1), 0);
      expect(ec.progress, 0);
      expect(ec.remainingIterationsCount, 1);

      // Forth iteration
      expect(ec.recede(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.remainingIterationsCount, 2);

      expect(ec.recede(1), 0);
      expect(ec.progress, 0);
      expect(ec.remainingIterationsCount, 2);

      // Third iteration
      expect(ec.recede(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.remainingIterationsCount, 3);

      expect(ec.recede(1), 0);
      expect(ec.progress, 0);
      expect(ec.remainingIterationsCount, 3);

      // Second iteration
      expect(ec.recede(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.remainingIterationsCount, 4);

      expect(ec.recede(1), 0);
      expect(ec.progress, 0);
      expect(ec.remainingIterationsCount, 4);

      // First iteration
      expect(ec.recede(1), 0);
      expect(ec.progress, 0.5);
      expect(ec.remainingIterationsCount, 5);

      expect(ec.recede(1), 0);
      expect(ec.progress, 0);
      expect(ec.remainingIterationsCount, 5);
      expect(ec.started, true);

      // Extra iterations
      expect(ec.recede(1), 1);
      expect(ec.progress, 0);
      expect(ec.remainingIterationsCount, 5);
    });

    test('errors', () {
      final ec = LinearEffectController(1);
      expect(
        () => RepeatedEffectController(InfiniteEffectController(ec), 1),
        failsAssert('child cannot be infinite'),
      );
      expect(
        () => RepeatedEffectController(ec, 0),
        failsAssert('repeatCount must be positive'),
      );
    });
  });
}
