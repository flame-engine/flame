import 'package:flame/src/effects2/simple_effect_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimpleEffectController', () {
    test('default', () {
      final ec = SimpleEffectController();
      expect(ec.duration, 0);
      expect(ec.delay, 0);
      expect(ec.isInfinite, false);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('simple with duration', () {
      final ec = SimpleEffectController(duration: 1);
      expect(ec.delay, 0);
      expect(ec.duration, 1);
      expect(ec.progress, 0);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.isInfinite, false);

      ec.update(0.5);
      expect(ec.progress, 0.5);
      expect(ec.started, true);
      expect(ec.completed, false);

      ec.update(0.5);
      expect(ec.progress, 1);
      expect(ec.started, true);
      expect(ec.completed, true);

      ec.update(0.00001);
      expect(ec.progress, 1);
      expect(ec.started, true);
      expect(ec.completed, true);
    });

    test('simple with delay', () {
      final ec = SimpleEffectController(delay: 1);
      expect(ec.isInfinite, false);
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.progress, 0);
      expect(ec.delay, 1);
      expect(ec.duration, 0);

      ec.update(0.5);
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.progress, 0);

      ec.update(0.5);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('duration + delay', () {
      final ec = SimpleEffectController(duration: 1, delay: 2);
      expect(ec.isInfinite, false);
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.duration, 1);
      expect(ec.delay, 2);
      expect(ec.progress, 0);

      ec.update(0.5);
      expect(ec.started, false);
      expect(ec.progress, 0);

      ec.update(0.5);
      expect(ec.started, false);
      expect(ec.progress, 0);

      ec.update(1);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);

      ec.update(0.5);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0.5);

      ec.update(0.5);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('reset', () {
      final ec = SimpleEffectController();
      ec.reset();
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('reset 2', () {
      final ec = SimpleEffectController(duration: 2, delay: 1);
      ec.update(3);
      expect(ec.completed, true);
      expect(ec.progress, 1);

      ec.reset();
      expect(ec.started, false);
      expect(ec.completed, false);
      expect(ec.progress, 0);

      ec.update(1);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);

      ec.update(1);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, closeTo(0.5, 1e-15));

      ec.update(1);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });
  });
}
