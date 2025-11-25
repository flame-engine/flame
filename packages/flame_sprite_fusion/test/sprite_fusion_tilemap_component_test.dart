import 'dart:math';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_sprite_fusion/flame_sprite_fusion.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpriteFusionTilemapComponent', () {
    late AssetBundle bundle;
    late Images images;

    setUp(() {
      bundle = TestAssetBundle(
        imageNames: ['spritesheet.png'],
        stringNames: ['map.json'],
      );
      images = Images(bundle: bundle);
    });

    test('creation test', () async {
      final tilemapData = SpriteFusionTilemapData(
        mapWidth: 10,
        mapHeight: 10,
        tileSize: 16,
        layers: [],
      );

      final spriteSheet = SpriteSheet(
        image: await images.load('spritesheet.png'),
        srcSize: Vector2.all(tilemapData.tileSize),
      );

      expect(
        () => SpriteFusionTilemapComponent(
          tilemapData: tilemapData,
          spriteSheet: spriteSheet,
        ),
        returnsNormally,
      );
    });

    test('loads map from file', () {
      expect(
        SpriteFusionTilemapComponent.load(
          mapJsonFile: 'map.json',
          spriteSheetFile: 'spritesheet.png',
          assetBundle: bundle,
          images: images,
          tilemapPrefix: '',
        ),
        completes,
      );
    });

    test('component size matches the map size', () async {
      final tilemapData = SpriteFusionTilemapData(
        mapWidth: 20,
        mapHeight: 40,
        tileSize: 16,
        layers: [],
      );

      final spriteSheet = SpriteSheet(
        image: await images.load('spritesheet.png'),
        srcSize: Vector2.all(tilemapData.tileSize),
      );

      final component = SpriteFusionTilemapComponent(
        tilemapData: tilemapData,
        spriteSheet: spriteSheet,
      );

      expect(
        component.size,
        Vector2(
          tilemapData.mapWidth * tilemapData.tileSize,
          tilemapData.mapHeight * tilemapData.tileSize,
        ),
      );
    });

    testGolden(
      'renders the map correctly',
      (game, tester) async {
        final map = await SpriteFusionTilemapComponent.load(
          mapJsonFile: 'map.json',
          spriteSheetFile: 'spritesheet.png',
          assetBundle: bundle,
          images: images,
          tilemapPrefix: '',
        );
        await game.add(map);
        await game.ready();
      },
      size: Vector2(360, 216),
      goldenFile: 'goldens/sprite_fusion_render_test.png',
    );

    testGolden(
      'position is respected when rendering',
      (game, tester) async {
        final map = await SpriteFusionTilemapComponent.load(
          mapJsonFile: 'map.json',
          spriteSheetFile: 'spritesheet.png',
          assetBundle: bundle,
          images: images,
          tilemapPrefix: '',
          position: Vector2(100, 100),
        );
        await game.add(map);
        await game.ready();
      },
      size: Vector2(360, 216),
      goldenFile: 'goldens/sprite_fusion_position_test.png',
    );

    testGolden(
      'anchor is respected when rendering',
      (game, tester) async {
        final map = await SpriteFusionTilemapComponent.load(
          mapJsonFile: 'map.json',
          spriteSheetFile: 'spritesheet.png',
          assetBundle: bundle,
          images: images,
          tilemapPrefix: '',
          anchor: Anchor.center,
        );
        await game.add(map);
        await game.ready();
      },
      size: Vector2(360, 216),
      goldenFile: 'goldens/sprite_fusion_anchor_test.png',
    );

    testGolden(
      'scale is respected when rendering',
      (game, tester) async {
        final map = await SpriteFusionTilemapComponent.load(
          mapJsonFile: 'map.json',
          spriteSheetFile: 'spritesheet.png',
          assetBundle: bundle,
          images: images,
          tilemapPrefix: '',
          scale: Vector2.all(0.5),
        );
        await game.add(map);
        await game.ready();
      },
      size: Vector2(360, 216),
      goldenFile: 'goldens/sprite_fusion_scale_test.png',
    );

    testGolden(
      'angle is respected when rendering',
      (game, tester) async {
        final map = await SpriteFusionTilemapComponent.load(
          mapJsonFile: 'map.json',
          spriteSheetFile: 'spritesheet.png',
          assetBundle: bundle,
          images: images,
          tilemapPrefix: '',
          angle: pi * 0.125,
        );
        await game.add(map);
        await game.ready();
      },
      size: Vector2(360, 216),
      goldenFile: 'goldens/sprite_fusion_angle_test.png',
    );
  });
}
