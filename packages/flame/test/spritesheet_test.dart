import 'package:flame/sprite.dart';
import 'package:flame/src/extensions/image.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockImage extends Mock implements Image {}

void main() {
  group('SpriteSheet', () {
    late final Image image = _MockImage();
    when(() => image.width).thenReturn(100);
    when(() => image.height).thenReturn(100);

    test('calculates all field from SpriteSheet', () {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(1, 2),
      );

      expect(spriteSheet.rows, 50);
      expect(spriteSheet.columns, 100);
    });

    test('calculates columns and rows with margin and spacing', () {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(1, 2),
        margin: 3,
        spacing: 2,
      );

      expect(spriteSheet.rows, 24);
      expect(spriteSheet.columns, 32);
    });

    test('calculates srcSize with margin and spacing', () {
      final spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: image,
        columns: 32,
        rows: 24,
        margin: 3,
        spacing: 2,
      );

      expect(spriteSheet.srcSize.x, 1);
      expect(spriteSheet.srcSize.y, 2);
    });

    test('assign the correct time in sprite', () {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      final animationTicker = spriteSheet
          .createAnimationWithVariableStepTimes(
            row: 1,
            stepTimes: [2.0, 3.0],
          )
          .createTicker();

      expect(animationTicker.totalDuration(), 5.0);
    });

    test(
      'throws error when stepTimes.length != spriteSheet.length',
      () {
        final spriteSheet = SpriteSheet(
          image: image,
          srcSize: Vector2(50, 50),
        );

        expect(
          () => spriteSheet.createAnimationWithVariableStepTimes(
            row: 1,
            stepTimes: [2.0],
          ),
          failsAssert('Lengths of stepTimes and sprites lists must be equal'),
        );
      },
    );

    test('return sprite based on row and column', () {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      expect(
        spriteSheet.getSprite(1, 1),
        isA<Sprite>().having(
          (sprite) => sprite.srcPosition,
          'srcPosition',
          equals(Vector2(50, 50)),
        ),
      );
    });

    test('return sprite based on id', () {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      expect(
        spriteSheet.getSpriteById(3),
        isA<Sprite>().having(
          (sprite) => sprite.srcPosition,
          'srcPosition',
          equals(Vector2(50, 50)),
        ),
      );
    });

    test('create sprite animation frame data based on row and column', () {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      expect(
        spriteSheet.createFrameData(1, 1, stepTime: 0.1),
        isA<SpriteAnimationFrameData>().having(
          (frame) => frame.srcPosition,
          'srcPosition',
          equals(Vector2(50, 50)),
        ),
      );
    });

    test('create sprite animation frame data based on id', () {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(50, 50),
      );

      expect(
        spriteSheet.createFrameDataFromId(3, stepTime: 0.1),
        isA<SpriteAnimationFrameData>().having(
          (frame) => frame.srcPosition,
          'srcPosition',
          equals(Vector2(50, 50)),
        ),
      );
    });
  });
}
