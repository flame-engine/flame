import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
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
      setUp(() async {
        TiledAtlas.atlasMap.clear();
        Flame.bundle = TestAssetBundle(
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
          mapPath: 'test/assets/isometric_plain.tmx',
        );
      });

      test('handles empty map', () async {
        final atlas = await TiledAtlas.fromTiledMap(
          TiledMap(height: 1, tileHeight: 1, tileWidth: 1, width: 1),
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
        final atlas = await TiledAtlas.fromTiledMap(
          simpleMap,
        );

        expect(atlas.offsets, hasLength(1));
        expect(atlas.atlas, isNotNull);
        expect(atlas.atlas!.width, 128);
        expect(atlas.atlas!.height, 74);

        expect(
          await imageToPng(atlas.atlas!),
          matchesGoldenFile('goldens/single_atlas.png'),
        );
      });

      test('returns cached atlas', () async {
        final atlas1 = await TiledAtlas.fromTiledMap(
          simpleMap,
        );
        final atlas2 = await TiledAtlas.fromTiledMap(
          simpleMap,
        );

        expect(atlas1, isNot(same(atlas2)));
        expect(atlas1.key, atlas2.key);
        expect(atlas2.atlas!.isCloneOf(atlas2.atlas!), isTrue);
      });

      test('packs complex maps with multiple images', () async {
        final component =
            await TiledComponent.load('isometric_plain.tmx', Vector2(128, 74));

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
    });
  });
}
