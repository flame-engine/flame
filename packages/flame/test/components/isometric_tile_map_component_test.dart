import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockImage extends Mock implements Image {
  MockImage(this.size);

  final Vector2 size;

  @override
  int get width => size.x.toInt();

  @override
  int get height => size.y.toInt();
}

class _MockSpriteSheet extends Mock implements SpriteSheet {
  _MockSpriteSheet(this.tileSize);

  final Vector2 tileSize;

  @override
  Image get image => MockImage(tileSize);
}

void main() {
  group('isometric tile map', () {
    final map = [
      [1, 1],
      [1, 1],
    ];

    test('conversions work back and forth', () {
      final tileSize = Vector2.all(32.0);
      final c = IsometricTileMapComponent(
        _MockSpriteSheet(tileSize),
        map,
        destTileSize: tileSize,
        tileHeight: 8.0,
      );

      final scales = [Vector2.all(0.1), Vector2.all(1), Vector2.all(2.0)];
      const blocks = [Block(0, 0), Block(1, 1), Block(-1, 0), Block(2, -10)];
      for (final scale in scales) {
        c.scale = scale;
        for (final block in blocks) {
          expect(c.getBlockRenderedAt(c.getBlockRenderPosition(block)), block);
          expect(c.getBlock(c.getBlockCenterPosition(block)), block);
        }
      }
    });

    test('center position', () {
      final tileSize = Vector2.all(32.0);
      final c = IsometricTileMapComponent(
        _MockSpriteSheet(tileSize),
        map,
        destTileSize: tileSize,
        tileHeight: 8.0,
      );

      expect(c.getBlockCenterPosition(const Block(0, 0)), closeToVector(0, 0));
    });

    test('height scaling', () {
      final tileSize = Vector2(156, 181);
      final c = IsometricTileMapComponent(
        _MockSpriteSheet(tileSize),
        map,
        destTileSize: tileSize,
      );
      //expect the block to be directly below
      expect(
        c.getBlockRenderPositionInts(1, 1),
        closeToVector(-156 / 2, 12.5, epsilon: 1e-13),
      );
    });
  });
}
