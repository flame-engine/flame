import 'dart:io';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
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

      final relativePathSingleImageMap = TiledMap(
        height: 1,
        tileHeight: 1,
        tileWidth: 1,
        width: 1,
        tilesets: [
          Tileset(
            // Simulate an external TSX tileset referenced by the map.
            source: 'tiles/isometric_plain_1.tsx',
            tileWidth: 128,
            tileHeight: 74,
            tileCount: 1,
            // Simulate an image path that is relative to the TSX file.
            image: const TiledImage(
              source: '../images/green.png',
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
        expect(atlas.key, 'assets/images/images/green.png');

        expect(
          images.containsKey('assets/images/images/green.png'),
          isTrue,
        );
        expect(images.keys, hasLength(1));

        expect(
          await imageToPng(atlas.atlas!),
          matchesGoldenFile('goldens/single_atlas.png'),
        );
      });

      test(
        'single image tileset with relative image path loads correctly',
        () async {
          final images = Images(bundle: bundle);
          final atlas = await TiledAtlas.fromTiledMap(
            relativePathSingleImageMap,
            images: images,
          );

          expect(atlas.offsets, hasLength(1));
          expect(atlas.atlas, isNotNull);
          expect(atlas.key, 'assets/images/../images/green.png');
        },
      );

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
          'assets/tiles/isometric_plain.tmx',
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

      test(
        'packs complex maps with multiple images using a custom spacing',
        () async {
          final component = await TiledComponent.load(
            'assets/tiles/isometric_plain.tmx',
            Vector2(128, 74),
            bundle: bundle,
            images: Images(bundle: bundle),
            atlasPackingSpacingX: 2,
            atlasPackingSpacingY: 2,
          );

          final atlas = TiledAtlas.atlasMap.values.first;
          expect(
            await imageToPng(atlas.atlas!),
            matchesGoldenFile('goldens/larger_atlas_with_spacing.png'),
          );
          expect(
            renderMapToPng(component),
            matchesGoldenFile(
              'goldens/larger_atlas_component_with_spacing.png',
            ),
          );
        },
      );

      test('can ignore tilesets in the packing', () async {
        await TiledComponent.load(
          'assets/tiles/isometric_plain.tmx',
          Vector2(128, 74),
          bundle: bundle,
          images: Images(bundle: bundle),
          tsxPackingFilter: (tileset) => tileset.name != 'isometric_plain_2',
        );

        final atlas = TiledAtlas.atlasMap.values.first;
        expect(
          await imageToPng(atlas.atlas!),
          matchesGoldenFile('goldens/larger_atlas_with_skipped_tileset.png'),
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

    group('external tileset image paths', () {
      // Tiled writes a tileset's image source relative to the `.tsx` file,
      // which is itself relative to the map. So for a map that references
      // `sets/edge.tsx`, an image source of `img/edge.png` means
      // `sets/img/edge.png`, and that is then resolved against the images
      // directory (`assets/images/` by default).
      //
      // Both cases below have as many path segments in the image source as in
      // the tileset source, which used to skip prepending the tileset's
      // folder, so the image was resolved as if it were relative to the map
      // instead (#4117).

      // Builds a map with a single external tileset, as if [tilesetSource]
      // had been read from the map and [imageSource] from the `.tsx`.
      TiledMap mapWith({
        required String tilesetSource,
        required String imageSource,
      }) {
        return TiledMap(
          height: 1,
          tileHeight: 1,
          tileWidth: 1,
          width: 1,
          tilesets: [
            Tileset(
              source: tilesetSource,
              tileWidth: 16,
              tileHeight: 16,
              tileCount: 1,
              image: TiledImage(source: imageSource, width: 16, height: 16),
            ),
          ],
        );
      }

      setUp(TiledAtlas.atlasMap.clear);

      test('resolves an image in a subfolder of the tileset', () async {
        // `sets/` + `img/edge.png`, not `img/edge.png` alone.
        const path = 'assets/images/sets/img/edge.png';
        // The bundle only serves this exact path, so loading the image from
        // anywhere else throws and fails the test.
        final images = Images(bundle: _ExactAssetBundle({path}));
        await TiledAtlas.fromTiledMap(
          mapWith(tilesetSource: 'sets/edge.tsx', imageSource: 'img/edge.png'),
          images: images,
        );

        // The image was loaded, and only from the expected path.
        expect(images.keys, [path]);
      });

      test('resolves an image in the parent folder of the tileset', () async {
        // `sets/` + `../edge.png`, with the `..` collapsed so the asset key is
        // one a real bundle can serve.
        const path = 'assets/images/edge.png';
        final images = Images(bundle: _ExactAssetBundle({path}));
        await TiledAtlas.fromTiledMap(
          mapWith(tilesetSource: 'sets/edge.tsx', imageSource: '../edge.png'),
          images: images,
        );

        expect(images.keys, [path]);
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
              'assets/tiles/single_tile_map_1.tmx',
              Vector2(16, 16),
              bundle: bundle,
              images: Images(bundle: bundle),
            ),
            TiledComponent.load(
              'assets/tiles/single_tile_map_2.tmx',
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
        },
      );
    });
  });
}

/// Serves `green_sprite.png` only under the exact [keys], so a test fails if a
/// tileset image is loaded from any other path.
class _ExactAssetBundle(final Set<String> keys) extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (!keys.contains(key)) {
      throw StateError('Unable to load asset: $key');
    }
    final bytes = await File('test/assets/green_sprite.png').readAsBytes();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}
