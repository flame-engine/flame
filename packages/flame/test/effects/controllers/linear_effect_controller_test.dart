import 'package:flame/src/effects/controllers/linear_effect_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LinearEffectController', () {
    test('[duration==0]', () {
      final ec = LinearEffectController(0);
      expect(ec.duration, 0);
      expect(ec.isInfinite, false);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);

      expect(ec.advance(0.1), 0.1);
      expect(ec.progress, 1);
    });

    test('[duration==0] reset', () {
      final ec = LinearEffectController(0);
      ec.setToStart();
      expect(ec.completed, true);
      expect(ec.progress, 1);
      ec.setToEnd();
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('[duration==1]', () {
      final ec = LinearEffectController(1);
      expect(ec.duration, 1);
      expect(ec.progress, 0);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.isInfinite, false);

      expect(ec.advance(0.5), 0);
      expect(ec.progress, 0.5);
      expect(ec.completed, false);

      expect(ec.advance(0.5), 0);
      expect(ec.progress, 1);
      expect(ec.completed, true);

      expect(ec.advance(0.00001), closeTo(0.00001, 1e-15));
      expect(ec.progress, 1);
      expect(ec.completed, true);

      expect(ec.recede(0.5), 0);
      expect(ec.progress, 0.5);

      expect(ec.recede(0.5), 0);
      expect(ec.progress, 0);

      expect(ec.recede(0.00001), closeTo(0.00001, 1e-15));
      expect(ec.progress, 0);
    });

    test('[duration==2] reset', () {
      final ec = LinearEffectController(2);
      expect(ec.advance(3), 1);
      expect(ec.completed, true);
      expect(ec.progress, 1);

      ec.setToStart();
      expect(ec.completed, false);
      expect(ec.progress, 0);

      expect(ec.advance(1), 0);
      expect(ec.progress, closeTo(0.5, 1e-15));
      expect(ec.completed, false);

      expect(ec.advance(1), 0);
      expect(ec.progress, 1);
      expect(ec.completed, true);

      expect(ec.advance(1), 1);
      expect(ec.progress, 1);
      expect(ec.completed, true);

      ec.setToStart();
      ec.setToEnd();
      expect(ec.progress, 1);
      expect(ec.completed, true);
    });
  });
}
