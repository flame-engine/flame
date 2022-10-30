import 'dart:math';

import 'package:flame/effects.dart';
import 'package:test/test.dart';

class MyRandom implements Random {
  double value = 0.5;

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => true;

  @override
  int nextInt(int max) => 1;
}

class MyRandomVariable extends RandomVariable {
  MyRandomVariable() : super(null);
  double value = 1.23;

  @override
  double nextValue() => value;
}

void main() {
  group('RandomEffectController', () {
    test('custom random', () {
      final randomVariable = MyRandomVariable();
      final ec = RandomEffectController(
        LinearEffectController(1000),
        randomVariable,
      );

      expect(ec.duration, 1.23);
      expect(ec.isRandom, true);
      expect(ec.isInfinite, false);
      expect(ec.progress, 0);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.advance(1), 0);
      expect(ec.advance(0.23), 0);
      expect(ec.completed, true);
      expect(ec.advance(1), 1);
      expect(ec.duration, 1.23);
    });

    test('.uniform', () {
      final random = MyRandom();
      final ec = RandomEffectController.uniform(
        LinearEffectController(1000),
        min: 0,
        max: 10,
        random: random,
      );
      expect(random.nextDouble(), 0.5);
      expect(ec.duration, 5);
      random.value = 0;
      ec.setToStart();
      expect(ec.duration, 0);
      random.value = 1;
      ec.setToStart();
      expect(ec.duration, 10);
    });

    test('.exponential', () {
      const n = 1000;
      final random = MyRandom();
      final ec = RandomEffectController.exponential(
        LinearEffectController(1e6),
        beta: 42,
        random: random,
      );
      var sum = 0.0;
      for (var i = 0; i < n; i++) {
        random.value = i / n;
        ec.setToStart();
        expect(ec.duration! >= 0, true);
        sum += ec.duration!;
      }
      expect(sum / n, closeTo(42, 400 / n));
    });
  });
}
