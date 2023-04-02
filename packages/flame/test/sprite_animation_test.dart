import 'package:flame/extensions.dart';
import 'package:flame/src/sprite_animation.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('SpriteAnimation', () {
    test('Throw assertion error on empty list of frames', () {
      expect(
        () => SpriteAnimation.spriteList([], stepTime: 1),
        failsAssert('There must be at least one animation frame'),
      );
    });

    test('Throw assertion error on non-positive step time', () {
      final sprite = MockSprite();
      expect(
        () => SpriteAnimation.spriteList([sprite], stepTime: 0),
        failsAssert('All frames must have positive durations'),
      );
      expect(
        () => SpriteAnimation.variableSpriteList(
          [sprite, sprite, sprite],
          stepTimes: [1, -1, 0],
        ),
        failsAssert('All frames must have positive durations'),
      );
    });

    test('Throw assertion error when setting non-positive step time', () {
      final sprite = MockSprite();
      final animation =
          SpriteAnimation.spriteList([sprite, sprite, sprite], stepTime: 1);
      expect(
        () => animation.stepTime = 0,
        failsAssert('Step time must be positive'),
      );
      expect(
        () => animation.variableStepTimes = [3, 2, 0],
        failsAssert('All step times must be positive'),
      );
    });

    test('onStart called for single-frame animation', () {
      var counter = 0;
      final sprite = MockSprite();
      final animationTicker =
          SpriteAnimation.spriteList([sprite], stepTime: 1, loop: false)
              .ticker()
            ..onStart = () => counter++;
      expect(counter, 0);
      animationTicker.update(0.5);
      expect(counter, 1);
      animationTicker.update(1);
      expect(counter, 1);
    });

    test('onComplete called for single-frame animation', () {
      var counter = 0;
      final sprite = MockSprite();
      final animationTicker =
          SpriteAnimation.spriteList([sprite], stepTime: 1, loop: false)
              .ticker()
            ..onComplete = () => counter++;
      expect(counter, 0);
      animationTicker.update(0.5);
      expect(counter, 0);
      animationTicker.update(0.5);
      expect(counter, 1);
      animationTicker.update(1);
      expect(counter, 1);
    });

    test(
        'verify call is being made at first of frame for multi-frame animation',
        () {
      var timePassed = 0.0;
      const dt = 0.03;
      var timesCalled = 0;
      final sprite = MockSprite();
      final spriteList = [sprite, sprite, sprite];
      final animationTicker =
          SpriteAnimation.spriteList(spriteList, stepTime: 1, loop: false)
              .ticker();
      animationTicker.onFrame = (index) {
        expect(timePassed, closeTo(index * 1.0, dt));
        timesCalled++;
      };
      while (timePassed <= spriteList.length) {
        timePassed += dt;
        animationTicker.update(dt);
      }
      expect(timesCalled, spriteList.length);
    });

    test('test sequence of event lifecycle for an animation', () {
      var animationStarted = false;
      var animationRunning = false;
      var animationComplete = false;
      final sprite = MockSprite();
      final animationTicker =
          SpriteAnimation.spriteList([sprite], stepTime: 1, loop: false)
              .ticker();
      animationTicker.onStart = () {
        expect(animationStarted, false);
        expect(animationRunning, false);
        expect(animationComplete, false);
        animationStarted = true;
        animationRunning = true;
      };
      animationTicker.onFrame = (index) {
        expect(animationStarted, true);
        expect(animationRunning, true);
        expect(animationComplete, false);
      };
      animationTicker.onComplete = () {
        expect(animationStarted, true);
        expect(animationRunning, true);
        expect(animationComplete, false);
        animationComplete = true;
      };
      animationTicker.update(1);
      expect(animationComplete, true);
    });

    test('completed completes', () {
      final sprite = MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      ).ticker();

      expectLater(animationTicker.completed, completes);

      animationTicker.update(1);
    });

    test(
      'completed completes when the animation has already completed',
      () async {
        final sprite = MockSprite();
        final animationTicker = SpriteAnimation.spriteList(
          [sprite],
          stepTime: 1,
          loop: false,
        ).ticker();

        animationTicker.update(1);
        expectLater(animationTicker.completed, completes);
      },
    );

    test(
      "completed doesn't complete when the animation is yet to complete",
      () async {
        final sprite = MockSprite();
        final animationTicker = SpriteAnimation.spriteList(
          [sprite],
          stepTime: 1,
          loop: false,
        ).ticker();

        expectLater(animationTicker.completed, doesNotComplete);
      },
    );

    test(
      "completed doesn't complete when animation is looping",
      () async {
        final sprite = MockSprite();
        final animationTicker =
            SpriteAnimation.spriteList([sprite], stepTime: 1).ticker();

        expectLater(animationTicker.completed, doesNotComplete);
      },
    );

    test(
      "completed doesn't complete when animation is looping and on last frame",
      () async {
        final sprite = MockSprite();
        final animationTicker =
            SpriteAnimation.spriteList([sprite], stepTime: 1).ticker();

        animationTicker.update(1);
        expectLater(animationTicker.completed, doesNotComplete);
      },
    );
  });

  group('SpriteAnimationData', () {
    test(
      'throws assertion error when amountPerRow is greater than amount',
      () {
        expect(
          () => SpriteAnimationData.variable(
            amount: 5,
            stepTimes: List.filled(5, 0.1),
            textureSize: Vector2(50, 50),
            amountPerRow: 10,
          ),
          failsAssert(),
        );
      },
    );

    test('creates a new SpriteAnimationData using the range constructor', () {
      final animationData = SpriteAnimationData.range(
        start: 6,
        end: 11,
        amount: 18,
        stepTimes: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6],
        amountPerRow: 6,
        textureSize: Vector2(1, 1),
      );
      expect(animationData.frames.length, 6);
      expect(
        animationData.frames.map((f) => f.stepTime),
        [0.1, 0.2, 0.3, 0.4, 0.5, 0.6],
      );
      expect(animationData.frames.map((f) => f.srcPosition), [
        Vector2(0, 1),
        Vector2(1, 1),
        Vector2(2, 1),
        Vector2(3, 1),
        Vector2(4, 1),
        Vector2(5, 1),
      ]);
    });
  });
}

class MockSprite extends Mock implements Sprite {}
