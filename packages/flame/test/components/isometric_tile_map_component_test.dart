import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockSpriteSheet extends Mock implements SpriteSheet {}

void main() {
  group('isometric tile map', () {
    final map = [
      [1, 1],
      [1, 1],
    ];
    test('conversions work back and forth', () {
      final c = IsometricTileMapComponent(
        _MockSpriteSheet(),
        map,
        destTileSize: Vector2.all(32.0),
        tileHeight: 8.0,
      );

      const blocks = [Block(0, 0), Block(1, 1), Block(-1, 0), Block(2, -10)];
      for (final block in blocks) {
        expect(c.getBlockRenderedAt(c.getBlockRenderPosition(block)), block);
        expect(c.getBlock(c.getBlockCenterPosition(block)), block);
      }
    });
    test('center position', () {
      final c = IsometricTileMapComponent(
        _MockSpriteSheet(),
        map,
        destTileSize: Vector2.all(32.0),
        tileHeight: 8.0,
      );

      expect(c.getBlockCenterPosition(const Block(0, 0)), closeToVector(0, 0));
    });
  });
}
