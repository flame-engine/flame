import 'package:flame/components.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Multiple pages atlas', () {
    const atlasPath =
        'test/assets/newFormat/multiplePages/MultiplePageAtlasMap.atlas';

    test('Texture atlas contains 12 Sprites', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );
      expect(atlas.sprites.length, 12);
    });

    test('findSpritesByName will return 8 sprites', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );
      final walkingSprites = atlas.findSpritesByName('robot_walk');
      expect(walkingSprites.length, 8);
    });

    test('findSpriteByName will return 1 sprite', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );
      final jumpSprite = atlas.findSpriteByName('robot_jump');
      expect(jumpSprite, isNotNull);
    });

    test('Sprite data is loaded correctly', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );

      final jumpSprite = atlas.findSpriteByName('robot_jump')!;
      expect(jumpSprite.rotate, true);
      expect(jumpSprite.name, 'robot_jump');
      expect(jumpSprite.srcPosition, Vector2(196, 260));
      expect(jumpSprite.packedHeight, 256);
      expect(jumpSprite.packedWidth, 192);
      expect(jumpSprite.index, -1);
      expect(jumpSprite.offsetY, 0);
      expect(jumpSprite.offsetX, 0);
      expect(jumpSprite.originalWidth, 192);
      expect(jumpSprite.originalHeight, 256);

      final walkSprite = atlas.findSpriteByName('robot_walk')!;
      expect(walkSprite.rotate, false);
      expect(walkSprite.name, 'robot_walk');
      expect(walkSprite.srcPosition, Vector2(2, 196));
      expect(walkSprite.packedHeight, 256);
      expect(walkSprite.packedWidth, 192);
      expect(walkSprite.index, 0);
      expect(walkSprite.offsetY, 0);
      expect(walkSprite.offsetX, 0);
      expect(walkSprite.originalWidth, 192);
      expect(walkSprite.originalHeight, 256);
    });
  });

  group('Single page atlas', () {
    const atlasPath =
        'test/assets/newFormat/singlePage/SinglePageAtlasMap.atlas';

    test('Texture atlas contains 12 Sprites', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );
      expect(atlas.sprites.length, 12);
    });

    test('findSpritesByName will return 8 sprites', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );
      final walkingSprites = atlas.findSpritesByName('robot_walk');
      expect(walkingSprites.length, 8);
    });

    test('findSpriteByName will return 1 sprite', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );
      final jumpSprite = atlas.findSpriteByName('robot_jump');
      expect(jumpSprite, isNotNull);
    });

    test('Sprite data is loaded correctly', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );

      final jumpSprite = atlas.findSpriteByName('robot_jump')!;
      expect(jumpSprite.rotate, false);
      expect(jumpSprite.name, 'robot_jump');
      expect(jumpSprite.srcPosition, Vector2(196, 518));
      expect(jumpSprite.packedHeight, 256);
      expect(jumpSprite.packedWidth, 192);
      expect(jumpSprite.index, -1);
      expect(jumpSprite.offsetY, 0);
      expect(jumpSprite.offsetX, 0);
      expect(jumpSprite.originalWidth, 192);
      expect(jumpSprite.originalHeight, 256);

      final walkSprite = atlas.findSpriteByName('robot_walk')!;
      expect(walkSprite.rotate, false);
      expect(walkSprite.name, 'robot_walk');
      expect(walkSprite.srcPosition, Vector2(2, 518));
      expect(walkSprite.packedHeight, 256);
      expect(walkSprite.packedWidth, 192);
      expect(walkSprite.index, 0);
      expect(walkSprite.offsetY, 0);
      expect(walkSprite.offsetX, 0);
      expect(walkSprite.originalWidth, 192);
      expect(walkSprite.originalHeight, 256);
    });
  });
}
