import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_typled/flame_typled.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typled/typled.dart';

Image _createTestImage(int width, int height) {
  final recorder = PictureRecorder();
  Canvas(recorder);
  final picture = recorder.endRecording();
  return picture.toImageSync(width, height);
}

void main() {
  group('TypledSpriteAtlas', () {
    late TypledSpriteAtlas atlas;

    setUp(() {
      final typledAtlas = TypledAtlas(
        imagePath: 'sprites.png',
        tileSize: 16,
        sprites: {
          'player': (0, 0, null, null),
          'enemy': (1, 0, null, null),
          'big_tree': (2, 0, 2, 3),
        },
      );
      // 3 cols x 3 rows of 16px tiles = 48x48 source image
      final image = _createTestImage(48, 48);
      atlas = TypledSpriteAtlas(
        atlas: typledAtlas,
        tileSize: 16,
        image: image,
        padding: 2,
      );
    });

    test('sprite returns correct source position for single tile', () {
      final sprite = atlas.sprite('player');
      // padding=2, paddedTileSize=18, col=0, row=0
      // srcPosition = (0*18+1, 0*18+1) = (1, 1)
      expect(sprite.srcPosition, Vector2(1, 1));
      expect(sprite.srcSize, Vector2(16, 16));
    });

    test('sprite returns correct source position for offset tile', () {
      final sprite = atlas.sprite('enemy');
      // col=1, row=0 => srcPosition = (1*18+1, 0*18+1) = (19, 1)
      expect(sprite.srcPosition, Vector2(19, 1));
      expect(sprite.srcSize, Vector2(16, 16));
    });

    test('sprite returns correct size for multi-tile sprite', () {
      final sprite = atlas.sprite('big_tree');
      // col=2, row=0 => srcPosition = (2*18+1, 0*18+1) = (37, 1)
      // size = (2*16, 3*16) = (32, 48)
      expect(sprite.srcPosition, Vector2(37, 1));
      expect(sprite.srcSize, Vector2(32, 48));
    });

    test('sprite throws for unknown sprite id', () {
      expect(
        () => atlas.sprite('nonexistent'),
        throwsA(isA<Exception>()),
      );
    });

    test('toBatch returns a SpriteBatch', () {
      final batch = atlas.toBatch();
      expect(batch, isNotNull);
    });
  });

  group('TypledSpriteAtlas (padding disabled)', () {
    late TypledSpriteAtlas atlas;

    setUp(() {
      final typledAtlas = TypledAtlas(
        imagePath: 'sprites.png',
        tileSize: 16,
        sprites: {
          'player': (0, 0, null, null),
          'enemy': (1, 0, null, null),
          'big_tree': (2, 0, 2, 3),
        },
      );
      final image = _createTestImage(48, 48);
      atlas = TypledSpriteAtlas(
        atlas: typledAtlas,
        tileSize: 16,
        image: image,
        padding: 0,
      );
    });

    test('sprite uses raw tile coordinates without padding', () {
      final sprite = atlas.sprite('player');
      // no padding: srcPosition = (0*16, 0*16) = (0, 0)
      expect(sprite.srcPosition, Vector2(0, 0));
      expect(sprite.srcSize, Vector2(16, 16));
    });

    test('sprite offset tile without padding', () {
      final sprite = atlas.sprite('enemy');
      // col=1, row=0 => srcPosition = (1*16, 0*16) = (16, 0)
      expect(sprite.srcPosition, Vector2(16, 0));
      expect(sprite.srcSize, Vector2(16, 16));
    });

    test('multi-tile sprite without padding', () {
      final sprite = atlas.sprite('big_tree');
      // col=2, row=0 => srcPosition = (2*16, 0) = (32, 0)
      // size = (2*16, 3*16) = (32, 48)
      expect(sprite.srcPosition, Vector2(32, 0));
      expect(sprite.srcSize, Vector2(32, 48));
    });
  });
}
