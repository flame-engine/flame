import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_asset_bundle.dart';
import 'test_image_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TiledAtlas', () {
    test('atlasKey returns sorted images', () {
      expect(
        TiledAtlas.atlasKey([
          const TiledImage(source: 'foo'),
          const TiledImage(source: 'bar'),
          const TiledImage(source: 'baz'),
        ]),
        'atlas{bar,baz,foo}',
      );
    });

    group('loadImages', () {
      late AssetBundle bundle;

      setUp(() {
        TiledAtlas.atlasMap.clear();
        bundle = TestAssetBundle(
          imageNames: [
            'images/blue.png',
            'images/purple_rock.png',
            'images/box2.png',
            'images/diamond.png',
            'images/gear.png',
            'images/green.png',
            'images/monkey_pink.png',
            'images/orange.png',
            'images/peach.png',
          ],
          stringNames: [
            'isometric_plain.tmx',
            'tiles/isometric_plain_1.tsx',
          ],
        );
      });

      test('handles empty map', () async {
        final atlas = await TiledAtlas.fromTiledMap(
          TiledMap(height: 1, tileHeight: 1, tileWidth: 1, width: 1),
          images: Images(bundle: bundle),
        );

        expect(atlas.atlas, isNull);
        expect(atlas.offsets, isEmpty);
        expect(atlas.batch, isNull);
        expect(atlas.key, 'atlas{empty}');
        expect(atlas.clone().key, 'atlas{empty}');
      });

      final simpleMap = TiledMap(
        height: 1,
        tileHeight: 1,
        tileWidth: 1,
        width: 1,
        tilesets: [
          Tileset(
            tileWidth: 128,
            tileHeight: 74,
            tileCount: 1,
            image: const TiledImage(
              source: 'images/green.png',
              width: 128,
              height: 74,
            ),
          ),
        ],
      );

      test('returns single image atlas for simple map', () async {
        final images = Images(bundle: bundle);
        final atlas = await TiledAtlas.fromTiledMap(
          simpleMap,
          images: images,
        );

        expect(atlas.offsets, hasLength(1));
        expect(atlas.atlas, isNotNull);
        expect(atlas.atlas!.width, 128);
        expect(atlas.atlas!.height, 74);
        expect(atlas.key, 'images/green.png');

        expect(images.containsKey('images/green.png'), isTrue);

        expect(
          await imageToPng(atlas.atlas!),
          matchesGoldenFile('goldens/single_atlas.png'),
        );
      });

      test('returns cached atlas', () async {
        final atlas1 = await TiledAtlas.fromTiledMap(
          simpleMap,
          images: Images(bundle: bundle),
        );
        final atlas2 = await TiledAtlas.fromTiledMap(
          simpleMap,
          images: Images(bundle: bundle),
        );

        expect(atlas1, isNot(same(atlas2)));
        expect(atlas1.key, atlas2.key);
        expect(atlas2.atlas!.isCloneOf(atlas2.atlas!), isTrue);
      });

      test('packs complex maps with multiple images', () async {
        final component = await TiledComponent.load(
          'isometric_plain.tmx',
          Vector2(128, 74),
          bundle: bundle,
          images: Images(bundle: bundle),
        );

        final atlas = TiledAtlas.atlasMap.values.first;
        expect(
          await imageToPng(atlas.atlas!),
          matchesGoldenFile('goldens/larger_atlas.png'),
        );
        expect(
          renderMapToPng(component),
          matchesGoldenFile('goldens/larger_atlas_component.png'),
        );
      });

      test('clearing cache', () async {
        await TiledAtlas.fromTiledMap(
          simpleMap,
          images: Images(bundle: bundle),
        );

        expect(TiledAtlas.atlasMap.isNotEmpty, true);

        TiledAtlas.clearCache();

        expect(TiledAtlas.atlasMap.isEmpty, true);
      });
    });

    group('Single tileset map', () {
      late AssetBundle bundle;

      setUp(() {
        TiledAtlas.atlasMap.clear();
        bundle = TestAssetBundle(
          imageNames: [
            '4_color_sprite.png',
          ],
          stringNames: [
            'single_tile_map_1.tmx',
            'single_tile_map_2.tmx',
          ],
        );
      });

      test(
          '''Two maps with a same tileset but different tile alignment should be rendered differently''',
          () async {
        final components = await Future.wait([
          TiledComponent.load(
            'single_tile_map_1.tmx',
            Vector2(16, 16),
            bundle: bundle,
            images: Images(bundle: bundle),
          ),
          TiledComponent.load(
            'single_tile_map_2.tmx',
            Vector2(16, 16),
            bundle: bundle,
            images: Images(bundle: bundle),
          ),
        ]);

        final atlas = TiledAtlas.atlasMap.values.first;
        final imageRendered_1 = renderMapToPng(components[0]);
        final imageRendered_2 = renderMapToPng(components[1]);

        expect(TiledAtlas.atlasMap.length, 1);
        expect(
          await imageToPng(atlas.atlas!),
          matchesGoldenFile('goldens/single_tile_atlas.png'),
        );
        expect(imageRendered_1, isNot(same(imageRendered_2)));
        expect(
          imageRendered_1,
          matchesGoldenFile('goldens/single_tile_map_1.png'),
        );
        expect(
          imageRendered_2,
          matchesGoldenFile('goldens/single_tile_map_2.png'),
        );
      });
    });
  });
}
