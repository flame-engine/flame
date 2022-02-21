import 'package:flame/sprite.dart';
import 'package:flame/src/extensions/image.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockImage extends Mock implements Image {}

void main() {
  group('SpriteSheet', () {
    late final Image image = MockImage();
    when(() => image.width).thenReturn(100);
    when(() => image.height).thenReturn(100);

    test('calculates all field from SpriteSheet', () async {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(1, 2),
      );

      expect(spriteSheet.rows, 50);
      expect(spriteSheet.columns, 100);
    });

    test('assign the correct time in sprite', () {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      final spriteAnimation = spriteSheet.createAnimationWithVariableStepTimes(
        row: 1,
        stepTimes: [2.0, 3.0],
      );

      expect(spriteAnimation.totalDuration(), 5.0);
    });

    test(
      'throws argument error when the length of stepTime is different from sprite',
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
          throwsA(isA<ArgumentError>()),
        );
      },
    );
  });
}
