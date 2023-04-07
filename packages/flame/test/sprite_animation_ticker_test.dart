import 'package:flame/sprite.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sprite_animation_test.dart';

void main() {
  group('SpriteAnimationTicker', () {
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

    test('completed completes when the animation has already completed',
        () async {
      final sprite = MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      ).ticker();

      animationTicker.update(1);
      expectLater(animationTicker.completed, completes);
    });

    test("completed doesn't complete when the animation is yet to complete",
        () async {
      final sprite = MockSprite();
      final animationTicker = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      ).ticker();

      expectLater(animationTicker.completed, doesNotComplete);
    });

    test("completed doesn't complete when animation is looping", () async {
      final sprite = MockSprite();
      final animationTicker =
          SpriteAnimation.spriteList([sprite], stepTime: 1).ticker();

      expectLater(animationTicker.completed, doesNotComplete);
    });

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
}
