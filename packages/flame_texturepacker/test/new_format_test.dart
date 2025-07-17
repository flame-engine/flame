import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCanvas extends Mock implements Canvas {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Multiple pages atlas', () {
    const atlasPath =
        'test/assets/newFormat/multiplePages/MultiplePageAtlasMap.atlas';
    const atlasTrimmedPath =
        'test/assets/newFormat/multiplePages/MultipleTrimmedPageAtlasMap.atlas';

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

    test('findSpriteByNameIndex will return 1 sprite', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );
      final jumpSprite = atlas.findSpriteByNameIndex('robot_jump', -1);
      expect(jumpSprite, isNotNull);
    });

    test('Sprite data is loaded correctly', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );

      final jumpSprite = atlas.findSpriteByName('robot_jump')!;
      expect(jumpSprite.region.rotate, true);
      expect(jumpSprite.region.name, 'robot_jump');
      expect(jumpSprite.srcPosition, Vector2(196, 260));
      expect(jumpSprite.region.height, 256);
      expect(jumpSprite.region.width, 192);
      expect(jumpSprite.region.index, -1);
      expect(jumpSprite.region.offsetY, 0);
      expect(jumpSprite.region.offsetX, 0);
      expect(jumpSprite.region.originalWidth, 192);
      expect(jumpSprite.region.originalHeight, 256);
      expect(jumpSprite.src, const Rect.fromLTWH(196, 260, 256, 192));
      expect(jumpSprite.srcSize, Vector2(192, 256));
      expect(jumpSprite.originalSize, Vector2(192, 256));
      expect(jumpSprite.offset, Vector2(0, 0));
      expect(jumpSprite.angle, math.pi / 2);

      final walkSprite = atlas.findSpriteByName('robot_walk')!;
      expect(walkSprite.region.rotate, false);
      expect(walkSprite.region.name, 'robot_walk');
      expect(walkSprite.srcPosition, Vector2(2, 196));
      expect(walkSprite.region.height, 256);
      expect(walkSprite.region.width, 192);
      expect(walkSprite.region.index, 0);
      expect(walkSprite.region.offsetY, 0);
      expect(walkSprite.region.offsetX, 0);
      expect(walkSprite.region.originalWidth, 192);
      expect(walkSprite.region.originalHeight, 256);
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
      expect(idleSprite.region.rotate, false);
      expect(idleSprite.region.name, 'robot_idle');
      expect(idleSprite.region.height, 182);
      expect(idleSprite.region.width, 130);
      expect(idleSprite.region.index, -1);
      expect(idleSprite.region.offsetY, 0);
      expect(idleSprite.region.offsetX, 31);
      expect(idleSprite.region.originalWidth, 192);
      expect(idleSprite.region.originalHeight, 256);
      expect(idleSprite.srcPosition, Vector2(0, 310));
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
      expect(walkSprite.region.rotate, true);
      expect(walkSprite.region.name, 'robot_walk');
      expect(walkSprite.region.height, 183);
      expect(walkSprite.region.width, 150);
      expect(walkSprite.region.index, 0);
      expect(walkSprite.region.offsetY, 2);
      expect(walkSprite.region.offsetX, 14);
      expect(walkSprite.region.originalWidth, 192);
      expect(walkSprite.region.originalHeight, 256);
      expect(walkSprite.srcPosition, Vector2(0, 0));
      expect(walkSprite.src, const Rect.fromLTWH(0, 0, 183, 150));
      expect(walkSprite.srcSize, Vector2(192, 256));
      expect(walkSprite.originalSize, Vector2(192, 256));
      expect(walkSprite.offset, Vector2(14, 2));
      expect(walkSprite.angle, math.pi / 2);

      final walkSpritePackedSize = walkSprite.clone(useOriginalSize: false);
      expect(walkSpritePackedSize.src, const Rect.fromLTWH(0, 0, 183, 150));
      expect(walkSpritePackedSize.srcSize, Vector2(150, 183));
      expect(walkSpritePackedSize.originalSize, Vector2(150, 183));
      expect(walkSpritePackedSize.offset, Vector2(0, 0));
      expect(walkSpritePackedSize.angle, math.pi / 2);
    });

    test('Sprite renders correctly', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );

      final sprite = atlas.findSpriteByName('robot_jump')!;
      final canvas = _MockCanvas();

      sprite.render(
        canvas,
        position: Vector2(100, 100),
        size: Vector2(384, 512),
      );

      expect(sprite.region.rotate, true);
      expect(sprite.offset, Vector2.zero());
      expect(sprite.originalSize, Vector2(192, 256));
      expect(sprite.srcSize, Vector2(192, 256));
      expect(sprite.angle, math.pi / 2);
    });

    test('Sprite renders with correct anchor point', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );

      final sprite = atlas.findSpriteByName('robot_jump')!;
      final canvas = _MockCanvas();

      sprite.render(
        canvas,
        position: Vector2(100, 100),
        size: Vector2(192, 256),
        anchor: Anchor.center,
      );

      expect(sprite.originalSize, Vector2(192, 256));
    });

    test('Sprite renders correctly with default position', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );

      final sprite = atlas.findSpriteByName('robot_jump')!;
      final canvas = _MockCanvas();

      sprite.render(
        canvas,
        size: Vector2(192, 256),
      );

      expect(sprite.originalSize, Vector2(192, 256));
    });
  });

  group('Single page atlas', () {
    const atlasPath =
        'test/assets/newFormat/singlePage/SinglePageAtlasMap.atlas';
    const atlasTrimmedPath =
        'test/assets/newFormat/singlePage/SingleTrimmedPageAtlasMap.atlas';

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
      expect(jumpSprite.region.rotate, false);
      expect(jumpSprite.region.name, 'robot_jump');
      expect(jumpSprite.region.height, 256);
      expect(jumpSprite.region.width, 192);
      expect(jumpSprite.region.index, -1);
      expect(jumpSprite.region.offsetY, 0);
      expect(jumpSprite.region.offsetX, 0);
      expect(jumpSprite.region.originalWidth, 192);
      expect(jumpSprite.region.originalHeight, 256);
      expect(jumpSprite.srcPosition, Vector2(196, 518));
      expect(jumpSprite.src, const Rect.fromLTWH(196, 518, 192, 256));
      expect(jumpSprite.srcSize, Vector2(192, 256));
      expect(jumpSprite.originalSize, Vector2(192, 256));
      expect(jumpSprite.offset, Vector2(0, 0));
      expect(jumpSprite.angle, 0);

      final walkSprite = atlas.findSpriteByName('robot_walk')!;
      expect(walkSprite.region.rotate, false);
      expect(walkSprite.region.name, 'robot_walk');
      expect(walkSprite.region.height, 256);
      expect(walkSprite.region.width, 192);
      expect(walkSprite.region.index, 0);
      expect(walkSprite.region.offsetY, 0);
      expect(walkSprite.region.offsetX, 0);
      expect(walkSprite.region.originalWidth, 192);
      expect(walkSprite.region.originalHeight, 256);
      expect(walkSprite.srcPosition, Vector2(2, 518));
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
      expect(idleSprite.region.rotate, false);
      expect(idleSprite.region.name, 'robot_idle');
      expect(idleSprite.region.height, 182);
      expect(idleSprite.region.width, 130);
      expect(idleSprite.region.index, -1);
      expect(idleSprite.region.offsetY, 0);
      expect(idleSprite.region.offsetX, 31);
      expect(idleSprite.region.originalWidth, 192);
      expect(idleSprite.region.originalHeight, 256);
      expect(idleSprite.srcPosition, Vector2(0, 160));
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
      expect(walkSprite.region.rotate, true);
      expect(walkSprite.region.name, 'robot_walk');
      expect(walkSprite.region.height, 183);
      expect(walkSprite.region.width, 150);
      expect(walkSprite.region.index, 0);
      expect(walkSprite.region.offsetY, 2);
      expect(walkSprite.region.offsetX, 14);
      expect(walkSprite.region.originalWidth, 192);
      expect(walkSprite.region.originalHeight, 256);
      expect(walkSprite.srcPosition, Vector2(191, 367));
      expect(walkSprite.src, const Rect.fromLTWH(191, 367, 183, 150));
      expect(walkSprite.srcSize, Vector2(192, 256));
      expect(walkSprite.originalSize, Vector2(192, 256));
      expect(walkSprite.offset, Vector2(14, 2));
      expect(walkSprite.angle, math.pi / 2);

      final walkSpritePackedSize = walkSprite.clone(useOriginalSize: false);
      expect(walkSpritePackedSize.src, const Rect.fromLTWH(191, 367, 183, 150));
      expect(walkSpritePackedSize.srcSize, Vector2(150, 183));
      expect(walkSpritePackedSize.originalSize, Vector2(150, 183));
      expect(walkSpritePackedSize.offset, Vector2(0, 0));
      expect(walkSpritePackedSize.angle, math.pi / 2);
    });

    test('Sprite renders correctly', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasTrimmedPath,
        fromStorage: true,
      );

      final sprite = atlas.findSpriteByName('robot_walk')!;
      final canvas = _MockCanvas();

      sprite.render(
        canvas,
        position: Vector2(100, 100),
        size: Vector2(384, 512),
      );

      expect(sprite.region.rotate, true);
      expect(sprite.offset, Vector2(14, 2));
      expect(sprite.originalSize, Vector2(192, 256));
      expect(sprite.srcSize, Vector2(192, 256));
      expect(sprite.angle, math.pi / 2);
    });

    test('Sprite renders with correct anchor point', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );

      final sprite = atlas.findSpriteByName('robot_jump')!;
      final canvas = _MockCanvas();

      sprite.render(
        canvas,
        position: Vector2(100, 100),
        size: Vector2(192, 256),
        anchor: Anchor.center,
      );

      expect(sprite.originalSize, Vector2(192, 256));
    });

    test('Sprite renders correctly with default position', () async {
      final atlas = await TexturePackerAtlas.load(
        atlasPath,
        fromStorage: true,
      );

      final sprite = atlas.findSpriteByName('robot_jump')!;
      final canvas = _MockCanvas();

      sprite.render(
        canvas,
        size: Vector2(192, 256),
      );

      expect(sprite.originalSize, Vector2(192, 256));
    });
  });
}
