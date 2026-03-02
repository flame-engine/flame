import 'package:flame/cache.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_asset_bundle.dart';
import 'test_image_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(TiledAtlas.atlasMap.clear);

  group('ImageLayer rendering', () {
    test(
      'image layer covers entire map',
      () async {
        final bundle = TestAssetBundle(
          imageNames: [
            'Tileset_Hexagonal_PointyTop_60x52_60x80.png',
            'images/gear.png',
            'green_sprite.png',
            'red_sprite.png',
          ],
          stringNames: ['image_layer_full_screen.tmx'],
        );

        final component = await TiledComponent.load(
          'image_layer_full_screen.tmx',
          Vector2.all(16),
          bundle: bundle,
          images: Images(bundle: bundle),
        );

        // The map is 15x15 tiles at 16x16, so the total size is 240x240
        expect(component.size, Vector2(240, 240));

        // Initialize game context
        final game = FlameGame();
        game.onGameResize(component.size);
        game.world.add(component);
        await component.onLoad();
        await game.ready();

        final pngData = await renderMapToPng(component);

        expect(
          pngData,
          matchesGoldenFile('goldens/image_layer_covers_map.png'),
        );
      },
    );
  });
}
