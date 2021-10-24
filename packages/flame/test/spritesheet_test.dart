import 'package:flame/sprite.dart';
import 'package:flame/src/extensions/image.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockImage extends Mock implements Image {}

void main() {
  late final Image image = MockImage();

  setUpAll(() {
    when(() => image.width).thenReturn(100);
    when(() => image.height).thenReturn(100);
  });

  group('SpriteSheet', () {
    test('calculates all field from SpriteSheet', () async {
      final sprite = SpriteSheet(
        image: image,
        srcSize: Vector2(1, 2),
      );

      expect(sprite.rows, 50);
      expect(sprite.columns, 100);
    });
  });

  group('SpriteSheet createAnimationVariable', () {
    test('assign the correct time in sprite', () {
      final sprite = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      final spriteAnimation = sprite.createAnimationWithVariableStepTimes(
        row: 1,
        stepTimes: [2.0, 3.0],
      );

      expect(spriteAnimation.totalDuration(), 5.0);
    });

    test(
        'throws assertion error when the length of stepTime is different from sprite',
        () {
      final sprite = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      expect(
        () => sprite.createAnimationWithVariableStepTimes(
          row: 1,
          stepTimes: [2.0],
        ),
        throwsException,
      );
    });
  });
}
