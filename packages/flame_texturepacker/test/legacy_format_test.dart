import 'package:flame/components.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multiple pages atlas', () {
    const atlasPath =
        'test/assets/legacy/multiplePages/MultiplePageAtlasMap.atlas';
    const atlasTrimmedPath =
        'test/assets/legacy/multiplePages/MultipleTrimmedPageAtlasMap.atlas';

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
      expect(jumpSprite.src, const Rect.fromLTWH(196, 260, 256, 192));
      expect(jumpSprite.srcSize, Vector2(192, 256));
      expect(jumpSprite.originalSize, Vector2(192, 256));
      expect(jumpSprite.offset, Vector2(0, 0));
      expect(jumpSprite.angle, 1.5707963267948966);

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
      expect(walkSprite.src, const Rect.fromLTWH(2, 196, 192, 256));
      expect(walkSprite.srcSize, Vector2(192, 256));
      expect(walkSprite.originalSize, Vector2(192, 256));
      expect(walkSprite.offset, Vector2(0, 0));
      expect(walkSprite.angle, 0);
    });

    test('Trimmed sprite data is loaded correctly', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasTrimmedPath,
        fromStorage: true,
      );

      final idleSprite = atlas.findSpriteByName('robot_idle')!;
      expect(idleSprite.rotate, false);
      expect(idleSprite.name, 'robot_idle');
      expect(idleSprite.srcPosition, Vector2(0, 310));
      expect(idleSprite.packedHeight, 182);
      expect(idleSprite.packedWidth, 130);
      expect(idleSprite.index, -1);
      expect(idleSprite.offsetY, 0);
      expect(idleSprite.offsetX, 31);
      expect(idleSprite.originalWidth, 192);
      expect(idleSprite.originalHeight, 256);
      expect(idleSprite.src, const Rect.fromLTWH(0, 310, 130, 182));
      expect(idleSprite.srcSize, Vector2(192, 256));
      expect(idleSprite.originalSize, Vector2(192, 256));
      expect(idleSprite.offset, Vector2(31, 0));
      expect(idleSprite.angle, 0);

      final idleSpritePackedSize = idleSprite.clone(useOriginalSize: false);
      expect(idleSpritePackedSize.src, const Rect.fromLTWH(0, 310, 130, 182));
      expect(idleSpritePackedSize.srcSize, Vector2(130, 182));
      expect(idleSpritePackedSize.originalSize, Vector2(130, 182));
      expect(idleSpritePackedSize.offset, Vector2(0, 0));
      expect(idleSpritePackedSize.angle, 0);

      final walkSprite = atlas.findSpriteByName('robot_walk')!;
      expect(walkSprite.rotate, true);
      expect(walkSprite.name, 'robot_walk');
      expect(walkSprite.srcPosition, Vector2(0, 0));
      expect(walkSprite.packedHeight, 183);
      expect(walkSprite.packedWidth, 150);
      expect(walkSprite.index, 0);
      expect(walkSprite.offsetY, 2);
      expect(walkSprite.offsetX, 14);
      expect(walkSprite.originalWidth, 192);
      expect(walkSprite.originalHeight, 256);
      expect(walkSprite.src, const Rect.fromLTWH(0, 0, 183, 150));
      expect(walkSprite.srcSize, Vector2(192, 256));
      expect(walkSprite.originalSize, Vector2(192, 256));
      expect(walkSprite.offset, Vector2(14, 2));
      expect(walkSprite.angle, 1.5707963267948966);

      final walkSpritePackedSize = walkSprite.clone(useOriginalSize: false);
      expect(walkSpritePackedSize.src, const Rect.fromLTWH(0, 0, 183, 150));
      expect(walkSpritePackedSize.srcSize, Vector2(150, 183));
      expect(walkSpritePackedSize.originalSize, Vector2(150, 183));
      expect(walkSpritePackedSize.offset, Vector2(0, 0));
      expect(walkSpritePackedSize.angle, 1.5707963267948966);
    });
  });
  group('Single page atlas', () {
    const atlasPath = 'test/assets/legacy/singlePage/SinglePageAtlasMap.atlas';
    const atlasTrimmedPath =
        'test/assets/legacy/singlePage/SingleTrimmedPageAtlasMap.atlas';

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
      expect(jumpSprite.src, const Rect.fromLTWH(196, 518, 192, 256));
      expect(jumpSprite.srcSize, Vector2(192, 256));
      expect(jumpSprite.originalSize, Vector2(192, 256));
      expect(jumpSprite.offset, Vector2(0, 0));
      expect(jumpSprite.angle, 0);

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
      expect(walkSprite.src, const Rect.fromLTWH(2, 518, 192, 256));
      expect(walkSprite.srcSize, Vector2(192, 256));
      expect(walkSprite.originalSize, Vector2(192, 256));
      expect(walkSprite.offset, Vector2(0, 0));
      expect(walkSprite.angle, 0);
    });

    test('Trimmed sprite data is loaded correctly', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasTrimmedPath,
        fromStorage: true,
      );

      final idleSprite = atlas.findSpriteByName('robot_idle')!;
      expect(idleSprite.rotate, false);
      expect(idleSprite.name, 'robot_idle');
      expect(idleSprite.srcPosition, Vector2(0, 160));
      expect(idleSprite.packedHeight, 182);
      expect(idleSprite.packedWidth, 130);
      expect(idleSprite.index, -1);
      expect(idleSprite.offsetY, 0);
      expect(idleSprite.offsetX, 31);
      expect(idleSprite.originalWidth, 192);
      expect(idleSprite.originalHeight, 256);
      expect(idleSprite.src, const Rect.fromLTWH(0, 160, 130, 182));
      expect(idleSprite.srcSize, Vector2(192, 256));
      expect(idleSprite.originalSize, Vector2(192, 256));
      expect(idleSprite.offset, Vector2(31, 0));
      expect(idleSprite.angle, 0);

      final idleSpritePackedSize = idleSprite.clone(useOriginalSize: false);
      expect(idleSpritePackedSize.src, const Rect.fromLTWH(0, 160, 130, 182));
      expect(idleSpritePackedSize.srcSize, Vector2(130, 182));
      expect(idleSpritePackedSize.originalSize, Vector2(130, 182));
      expect(idleSpritePackedSize.offset, Vector2(0, 0));
      expect(idleSpritePackedSize.angle, 0);

      final walkSprite = atlas.findSpriteByName('robot_walk')!;
      expect(walkSprite.rotate, true);
      expect(walkSprite.name, 'robot_walk');
      expect(walkSprite.srcPosition, Vector2(191, 367));
      expect(walkSprite.packedHeight, 183);
      expect(walkSprite.packedWidth, 150);
      expect(walkSprite.index, 0);
      expect(walkSprite.offsetY, 2);
      expect(walkSprite.offsetX, 14);
      expect(walkSprite.originalWidth, 192);
      expect(walkSprite.originalHeight, 256);
      expect(walkSprite.src, const Rect.fromLTWH(191, 367, 183, 150));
      expect(walkSprite.srcSize, Vector2(192, 256));
      expect(walkSprite.originalSize, Vector2(192, 256));
      expect(walkSprite.offset, Vector2(14, 2));
      expect(walkSprite.angle, 1.5707963267948966);

      final walkSpritePackedSize = walkSprite.clone(useOriginalSize: false);
      expect(walkSpritePackedSize.src, const Rect.fromLTWH(191, 367, 183, 150));
      expect(walkSpritePackedSize.srcSize, Vector2(150, 183));
      expect(walkSpritePackedSize.originalSize, Vector2(150, 183));
      expect(walkSpritePackedSize.offset, Vector2(0, 0));
      expect(walkSpritePackedSize.angle, 1.5707963267948966);
    });
  });
}
