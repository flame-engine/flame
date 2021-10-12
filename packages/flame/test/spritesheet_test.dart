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
    test('Should calc all field from SpriteSheet', () async {
      final sprite = SpriteSheet(
        image: image,
        srcSize: Vector2(1, 2),
      );

      expect(sprite.rows, 50);
      expect(sprite.columns, 100);
    });
  });

  group('SpriteSheet createAnimationVariable', () {
    test('Should put correct time in sprite', () {
      final sprite = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      final spriteAnimation = sprite.createAnimationVariable(
        row: 1,
        stepTime: [2.0, 3.0],
      );

      expect(spriteAnimation.totalDuration(), 5.0);
    });

    test(
        'Should throw assetetion error'
        ' When the size of stepTime is different from sprite', () {
      final sprite = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      expect(
        () => sprite.createAnimationVariable(
          row: 1,
          stepTime: [2.0],
        ),
        throwsAssertionError,
      );
    });
  });
}
