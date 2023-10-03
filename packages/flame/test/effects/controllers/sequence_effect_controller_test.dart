import 'dart:math';

import 'package:flame/src/effects/controllers/infinite_effect_controller.dart';
import 'package:flame/src/effects/controllers/linear_effect_controller.dart';
import 'package:flame/src/effects/controllers/sequence_effect_controller.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('SequenceEffectController', () {
    test('basic properties', () {
      final ec = SequenceEffectController([
        LinearEffectController(1),
        LinearEffectController(2),
        LinearEffectController(3),
      ]);
      expect(ec.isRandom, false);
      expect(ec.isInfinite, false);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.duration, 6);
      expect(ec.progress, 0);
      expect(ec.children.length, 3);
    });

    test('reset', () {
      final ec = SequenceEffectController([
        LinearEffectController(1),
        LinearEffectController(2),
        LinearEffectController(3),
      ]);
      ec.setToEnd();
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);
      expect(ec.children.every((c) => c.completed), true);

      ec.setToStart();
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);
      expect(ec.children.every((c) => c.progress == 0), true);
    });

    testRandom('advance', (Random random) {
      final ec = SequenceEffectController([
        LinearEffectController(1),
        LinearEffectController(2),
        LinearEffectController(3),
      ]);

      var totalTime = 0.0;
      while (totalTime <= 6) {
        expect(
          ec.progress,
          closeTo(
            switch (totalTime) {
              <= 1 => totalTime,
              <= 3 => (totalTime - 1) / 2,
              _ => (totalTime - 3) / 3,
            },
            1e-15,
          ),
        );
        final dt = random.nextDouble();
        totalTime += dt;
        ec.advance(dt);
      }
      expect(ec.completed, true);
      expect(ec.progress, 1);
      expect(ec.children.every((c) => c.completed), true);
    });

    testRandom('recede', (Random random) {
      final ec = SequenceEffectController([
        LinearEffectController(1),
        LinearEffectController(2),
        LinearEffectController(3),
      ]);
      ec.setToEnd();

      var totalTime = 6.0;
      while (totalTime >= 0) {
        expect(
          ec.progress,
          closeTo(
            switch (totalTime) {
              <= 1 => totalTime,
              <= 3 => (totalTime - 1) / 2,
              _ => (totalTime - 3) / 3,
            },
            1e-14,
          ),
        );
        final dt = random.nextDouble() * 0.1;
        totalTime -= dt;
        ec.recede(dt);
      }
      expect(ec.completed, false);
      expect(ec.progress, 0);
      expect(ec.children.every((c) => c.progress == 0), true);
    });

    test('errors', () {
      expect(
        () => SequenceEffectController([]),
        failsAssert('List of controllers cannot be empty'),
      );
      expect(
        () => SequenceEffectController(
          [InfiniteEffectController(LinearEffectController(1))],
        ),
        failsAssert('Children controllers cannot be infinite'),
      );
    });
  });
}
