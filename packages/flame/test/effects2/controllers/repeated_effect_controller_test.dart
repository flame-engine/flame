import 'package:flame/src/effects2/controllers/infinite_effect_controller.dart';
import 'package:flame/src/effects2/controllers/linear_effect_controller.dart';
import 'package:flame/src/effects2/controllers/repeated_effect_controller.dart';
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
    });

    test('advance', () {
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
