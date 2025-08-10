import 'package:flame/sprite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('SpriteAnimationTicker', () {
    test('onStart called for single-frame animation', () {
      var counter = 0;
      final sprite = _MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      ).createTicker()..onStart = () => counter++;

      expect(counter, 0);
      animationTicker.update(0.5);
      expect(counter, 1);
      animationTicker.update(1);
      expect(counter, 1);
    });

    test('onComplete called for single-frame animation', () {
      var counter = 0;
      final sprite = _MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      ).createTicker()..onComplete = () => counter++;
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
        final sprite = _MockSprite();
        final spriteList = [sprite, sprite, sprite];
        final animationTicker = SpriteAnimation.spriteList(
          spriteList,
          stepTime: 1,
          loop: false,
        ).createTicker();
        animationTicker.onFrame = (index) {
          expect(timePassed, closeTo(index * 1.0, dt));
          timesCalled++;
        };
        while (timePassed <= spriteList.length) {
          timePassed += dt;
          animationTicker.update(dt);
        }
        expect(timesCalled, spriteList.length);
      },
    );

    test('test sequence of event lifecycle for an animation', () {
      var animationStarted = false;
      var animationRunning = false;
      var animationComplete = false;
      final sprite = _MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      ).createTicker();
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
      final sprite = _MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      ).createTicker();

      expectLater(animationTicker.completed, completes);

      animationTicker.update(1);
    });

    test('completed completes when the animation has already completed', () {
      final sprite = _MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      ).createTicker();

      animationTicker.update(1);
      expectLater(animationTicker.completed, completes);
    });

    test(
      "completed doesn't complete when the animation is yet to complete",
      () {
        final sprite = _MockSprite();
        final animationTicker = SpriteAnimation.spriteList(
          [sprite],
          stepTime: 1,
          loop: false,
        ).createTicker();

        expectLater(animationTicker.completed, doesNotComplete);
      },
    );

    test("completed doesn't complete when animation is looping", () {
      final sprite = _MockSprite();
      final animationTicker = SpriteAnimation.spriteList([
        sprite,
      ], stepTime: 1).createTicker();

      expectLater(animationTicker.completed, doesNotComplete);
    });

    test(
      "completed doesn't complete when animation is looping and on last frame",
      () {
        final sprite = _MockSprite();
        final animationTicker = SpriteAnimation.spriteList([
          sprite,
        ], stepTime: 1).createTicker();

        animationTicker.update(1);
        expectLater(animationTicker.completed, doesNotComplete);
      },
    );

    test("completed doesn't complete after the animation is reset", () {
      final sprite = _MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      ).createTicker();

      animationTicker.completed;
      animationTicker.update(1);
      expect(animationTicker.completeCompleter!.isCompleted, true);

      animationTicker.reset();
      animationTicker.completed;
      expect(animationTicker.completeCompleter!.isCompleted, false);
    });

    test('paused pauses ticket', () {
      final sprite = _MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite, sprite],
        stepTime: 1,
        loop: false,
      ).createTicker();

      expect(animationTicker.isPaused, false);
      expect(animationTicker.currentIndex, 0);
      animationTicker.update(1);
      expect(animationTicker.currentIndex, 1);
      animationTicker.paused = true;
      expect(animationTicker.isPaused, true);
      animationTicker.update(1);
      expect(animationTicker.currentIndex, 1);
      animationTicker.reset();
      expect(animationTicker.currentIndex, 0);
      expect(animationTicker.isPaused, false);
    });
  });
}

class _MockSprite extends Mock implements Sprite {}
