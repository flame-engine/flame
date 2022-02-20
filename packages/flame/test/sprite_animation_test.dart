import 'package:flame/src/sprite_animation.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('SpriteAnimation', () {
    test('Error on empty list of frames', () {
      expect(
        () => SpriteAnimation.spriteList([], stepTime: 1),
        failsAssert('There must be at least one animation frame'),
      );
    });

    test('Error on non-positive step time', () {
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

    test('Error when setting non-positive step time', () {
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
  });
}

class MockSprite extends Mock implements Sprite {}
