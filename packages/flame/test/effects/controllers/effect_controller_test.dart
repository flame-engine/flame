import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EffectController', () {
    test('forward', () {
      final ec = EffectController(duration: 1.0);
      expect(ec.isInfinite, false);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0.0);

      ec.advance(0.5);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0.5);

      ec.advance(0.5);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1.0);

      // Updating controller after it already finished is a no-op
      ec.advance(0.5);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1.0);
    });

    test('forward x 2', () {
      final ec = EffectController(duration: 1, repeatCount: 2);
      expect(ec.started, true);
      expect(ec.progress, 0);

      ec.advance(1);
      expect(ec.progress, 1);
      ec.advance(1e-10);
      expect(ec.progress, closeTo(1e-10, 1e-15));
      ec.advance(1);
      expect(ec.progress, 1);
      expect(ec.completed, true);
    });

    test('forward + delay', () {
      final ec = EffectController(duration: 1.0, startDelay: 0.2);
      expect(ec.isInfinite, false);

      // initial delay
      for (var i = 0; i < 20; i++) {
        expect(ec.started, false);
        expect(ec.completed, false);
        expect(ec.progress, 0);
        ec.advance(0.01);
      }
      expect(ec.progress, closeTo(0, 1e-10));

      // progress from 0 to 1 over 1s
      for (var i = 0; i < 100; i++) {
        ec.advance(0.01);
        expect(ec.started, true);
        expect(ec.progress, closeTo((i + 1) / 100, 1e-10));
      }

      // final update, to account for any rounding errors
      ec.advance(1e-10);
      expect(ec.completed, true);
      expect(ec.progress, 1);
    });

    test('forward + atMax', () {
      final ec = EffectController(duration: 1, atMaxDuration: 0.5);
      expect(ec.duration, 1.5);
      expect(ec.isInfinite, false);
      expect(ec.progress, 0);

      ec.advance(1.5);
      expect(ec.progress, 1);
      expect(ec.started, true);
      expect(ec.completed, true);
    });

    test('(forward + reverse) x 5', () {
      final ec = EffectController(
        startDelay: 1.0,
        duration: 2.0,
        reverseDuration: 1.0,
        atMaxDuration: 0.2,
        atMinDuration: 0.5,
        repeatCount: 5,
      );
      expect(ec.isInfinite, false);
      expect(ec.progress, 0);
      expect(ec.started, false);
      expect(ec.completed, false);

      // Initial delay
      ec.advance(1.0);
      expect(ec.started, true);
      expect(ec.progress, 0);

      // 5 iterations
      for (var iteration = 0; iteration < 5; iteration++) {
        // forward
        for (var i = 0; i < 200; i++) {
          ec.advance(0.01);
          expect(ec.progress, closeTo((i + 1) / 200, 1e-10));
        }
        // atPeak
        for (var i = 0; i < 20; i++) {
          ec.advance(0.01);
          expect(ec.progress, closeTo(1, i == 19 ? 1e-10 : 0));
        }
        // reverse
        for (var i = 0; i < 100; i++) {
          ec.advance(0.01);
          expect(ec.progress, closeTo((99 - i) / 100, 1e-10));
        }
        // atPit
        for (var i = 0; i < 50; i++) {
          ec.advance(0.01);
          expect(ec.progress, closeTo(0, i == 49 ? 1e-10 : 0));
        }
      }

      // In the end, the progress will remain at zero
      ec.advance(1e-10);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 0);
    });

    testRandom('infinite', (Random random) {
      const duration = 1.4;
      final ec = EffectController(duration: duration, infinite: true);
      expect(ec.isInfinite, true);
      expect(ec.progress, 0);
      expect(ec.started, true);
      expect(ec.completed, false);

      var stageTime = 0.0;
      for (var i = 0; i < 100; i++) {
        final dt = random.nextDouble() * 0.3;
        ec.advance(dt);
        stageTime += dt;
        if (stageTime >= duration) {
          stageTime -= duration;
        }
        expect(ec.progress, closeTo(stageTime / duration, 1e-10));
      }

      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.isInfinite, true);
    });

    test('with speed', () async {
      final ec = EffectController(speed: 1);
      expect(ec.duration, isNaN);

      final game = FlameGame()..onGameResize(Vector2.zero());
      final component = PositionComponent();
      final effect = MoveEffect.by(Vector2(10, 0), ec);
      component.add(effect);
      await game.ensureAdd(component);
      game.update(0);
      expect(ec.duration, 10);
    });

    test('curved with speed', () {
      final ec = EffectController(speed: 1, curve: Curves.ease);
      expect(ec, isA<SpeedEffectController>());
      expect(
        (ec as SpeedEffectController).child,
        isA<CurvedEffectController>(),
      );
    });

    test('reverse speed-1', () {
      final ec = EffectController(speed: 1, alternate: true);
      expect(ec, isA<SequenceEffectController>());
      final seq = (ec as SequenceEffectController).children;
      expect(seq.length, 2);
      expect(seq[0], isA<SpeedEffectController>());
      expect(seq[1], isA<SpeedEffectController>());
      expect(
        (seq[0] as SpeedEffectController).child,
        isA<LinearEffectController>(),
      );
      expect(
        (seq[1] as SpeedEffectController).child,
        isA<ReverseLinearEffectController>(),
      );
    });

    test('reverse speed-2', () {
      final ec = EffectController(speed: 1, reverseSpeed: 2);
      expect(ec, isA<SequenceEffectController>());
      final seq = (ec as SequenceEffectController).children;
      expect(seq.length, 2);
      expect(seq[0], isA<SpeedEffectController>());
      expect(seq[1], isA<SpeedEffectController>());
      expect((seq[0] as SpeedEffectController).speed, 1);
      expect((seq[1] as SpeedEffectController).speed, 2);
    });

    test('reset', () {
      final ec = EffectController(duration: 1.23);
      expect(ec.started, true);
      expect(ec.progress, 0);

      ec.advance(0.4);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, closeTo(0.4 / 1.23, 1e-10));

      ec.setToStart();
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);

      ec.advance(0.5);
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, closeTo(0.5 / 1.23, 1e-10));

      ec.advance(1);
      expect(ec.started, true);
      expect(ec.completed, true);
      expect(ec.progress, 1);

      ec.setToStart();
      expect(ec.started, true);
      expect(ec.completed, false);
      expect(ec.progress, 0);
    });

    test('curve', () {
      const curve = Curves.easeIn;
      final ec = EffectController(
        duration: 1,
        curve: curve,
        reverseDuration: 0.8,
      );
      expect(ec.started, true);
      expect(ec.duration, 1.8);

      for (var i = 0; i < 100; i++) {
        ec.advance(0.01);
        // Precision is less for final iteration, because it may flip over
        // to the backwards curve.
        final epsilon = i == 99 ? 1e-6 : 1e-10;
        expect(ec.progress, closeTo(curve.transform((i + 1) / 100), epsilon));
      }
      for (var i = 0; i < 80; i++) {
        ec.advance(0.01);
        expect(
          ec.progress,
          closeTo(curve.flipped.transform(1 - (i + 1) / 80), 1e-10),
        );
      }
      ec.advance(1e-10);
      expect(ec.completed, true);
      expect(ec.progress, 0);
    });

    test('reverse curve', () {
      const curve = Curves.easeInQuad;
      final ec = EffectController(
        duration: 1,
        reverseDuration: 1,
        reverseCurve: curve,
      );
      expect(ec.started, true);
      expect(ec.duration, 2);

      ec.advance(1);
      expect(ec.progress, 1);
      expect(ec.completed, false);

      for (var i = 0; i < 100; i++) {
        ec.advance(0.01);
        expect(ec.progress, closeTo(curve.transform(1 - (i + 1) / 100), 1e-10));
      }
      ec.advance(1e-10);
      expect(ec.completed, true);
    });

    test('reverse curve with speed', () {
      final ec = EffectController(
        speed: 1,
        curve: Curves.easeIn,
        alternate: true,
      );
      expect(ec, isA<SequenceEffectController>());
      final seq = (ec as SequenceEffectController).children;
      expect(seq.length, 2);
      expect(seq[0], isA<SpeedEffectController>());
      expect(seq[1], isA<SpeedEffectController>());
      expect(
        (seq[0] as SpeedEffectController).child,
        isA<CurvedEffectController>(),
      );
      expect(
        (seq[1] as SpeedEffectController).child,
        isA<ReverseCurvedEffectController>(),
      );
    });

    group('errors', () {
      test('empty', () {
        expect(
          EffectController.new,
          failsAssert('Either duration or speed must be specified'),
        );
      });

      test('duration and speed', () {
        expect(
          () => EffectController(duration: 1, speed: 1),
          failsAssert(
            'Both duration and speed cannot be specified at the same time',
          ),
        );
      });

      test('reverseDuration and reverseSpeed', () {
        expect(
          () => EffectController(
            duration: 1,
            reverseDuration: 1,
            reverseSpeed: 1,
          ),
          failsAssert(
            'Both reverseDuration and reverseSpeed cannot be specified at the '
            'same time',
          ),
        );
      });

      test('negative duration', () {
        expect(
          () => EffectController(duration: -1),
          failsAssert('Duration cannot be negative: -1.0'),
        );
      });

      test('negative reverse duration', () {
        expect(
          () => EffectController(duration: 1, reverseDuration: -1),
          failsAssert('Reverse duration cannot be negative: -1.0'),
        );
      });

      test('zero speed', () {
        expect(
          () => EffectController(speed: 0),
          failsAssert('Speed must be positive: 0.0'),
        );
      });

      test('negative speed', () {
        expect(
          () => EffectController(speed: -1),
          failsAssert('Speed must be positive: -1.0'),
        );
      });

      test('zero reverseSpeed', () {
        expect(
          () => EffectController(speed: 1, reverseSpeed: 0),
          failsAssert('Reverse speed must be positive: 0.0'),
        );
      });

      test('negative reverseSpeed', () {
        expect(
          () => EffectController(speed: 1, reverseSpeed: -1),
          failsAssert('Reverse speed must be positive: -1.0'),
        );
      });

      test('zero repeat count', () {
        expect(
          () => EffectController(duration: 1, repeatCount: 0),
          failsAssert('Repeat count must be positive: 0'),
        );
      });

      test('negative repeat count', () {
        expect(
          () => EffectController(duration: 1, repeatCount: -1),
          failsAssert('Repeat count must be positive: -1'),
        );
      });

      test('repeated and infinite', () {
        expect(
          () => EffectController(
            duration: 1,
            infinite: true,
            repeatCount: 3,
          ),
          failsAssert('An infinite effect cannot have a repeat count'),
        );
      });

      test('negative startDelay', () {
        expect(
          () => EffectController(duration: 1, startDelay: -1),
          failsAssert('Start delay cannot be negative: -1.0'),
        );
      });

      test('negative atMinDuration', () {
        expect(
          () => EffectController(duration: 1, atMinDuration: -1),
          failsAssert('At-min duration cannot be negative: -1.0'),
        );
      });

      test('negative atMaxDuration', () {
        expect(
          () => EffectController(duration: 1, atMaxDuration: -1),
          failsAssert('At-max duration cannot be negative: -1.0'),
        );
      });
    });
  });
}
