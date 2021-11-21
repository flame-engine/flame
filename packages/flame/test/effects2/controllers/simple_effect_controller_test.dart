import 'package:flame/src/effects2/controllers/simple_effect_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimpleEffectController', () {
    test('duration == 0', () {
      final ec = SimpleEffectController();
      expect(ec.duration, 0);
      expect(ec.isInfinite, false);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('duration == 1', () {
      final ec = SimpleEffectController(1);
      expect(ec.duration, 1);
      expect(ec.progress, 0);
      expect(ec.completed, false);
      expect(ec.isInfinite, false);

      expect(ec.advance(0.5), 0);
      expect(ec.progress, 0.5);
      expect(ec.completed, false);

      expect(ec.advance(0.5), 0);
      expect(ec.progress, 1);
      expect(ec.completed, true);

      expect(ec.advance(0.00001), 0.00001);
      expect(ec.progress, 1);
      expect(ec.completed, true);
    });

    test('reset', () {
      final ec = SimpleEffectController();
      ec.reset();
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('reset 2', () {
      final ec = SimpleEffectController(2);
      expect(ec.advance(3), 1);
      expect(ec.completed, true);
      expect(ec.progress, 1);

      ec.reset();
      expect(ec.completed, false);
      expect(ec.progress, 0);

      expect(ec.advance(1), 0);
      expect(ec.completed, false);
      expect(ec.progress, closeTo(0.5, 1e-15));

      expect(ec.advance(1), 0);
      expect(ec.completed, false);
      expect(ec.progress, 1);

      expect(ec.advance(1), 1);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });
  });
}
