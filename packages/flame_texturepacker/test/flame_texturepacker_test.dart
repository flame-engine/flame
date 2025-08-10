import 'dart:io';

import 'package:flame/cache.dart';
import 'package:flame/game.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TexturepackerLoader', () {
    const atlasPath =
        'test/assets/newFormat/multiplePages/MultiplePageAtlasMap.atlas';
    const atlasWhitelistPath = 'test/assets/whitelist/whitelist_test.atlas';
    const atlasImage1 =
        'test/assets/newFormat/multiplePages/MultiplePageAtlasMap.png';

    test('load atlas from storage', () async {
      final flameGame = FlameGame();
      final atlas = await flameGame.atlasFromStorage(atlasPath);

      expect(atlas, isNotNull);
      expect(atlas.sprites.length, equals(12));

      final firstSprite = atlas.findSpriteByName('robot_walk');
      expect(firstSprite, isNotNull);
      expect(firstSprite!.srcSize, isNotNull);
      expect(firstSprite.srcPosition, isNotNull);
    });

    test('load atlas from assets', () async {
      final bundle = _MockAssetBundle();
      when(
        () => bundle.loadString(any()),
      ).thenAnswer((_) async => File(atlasPath).readAsString());
      when(() => bundle.load(any())).thenAnswer(
        (_) async => ByteData.sublistView(
          File(atlasImage1).readAsBytesSync(),
        ),
      );

      final flameGame = FlameGame()
        ..assets = AssetsCache(bundle: bundle, prefix: '')
        ..images = Images(bundle: bundle, prefix: '');

      final atlas = await flameGame.atlasFromAssets(atlasPath);

      expect(atlas, isNotNull);
      expect(atlas.sprites.length, equals(12));

      final firstSprite = atlas.findSpriteByName('robot_walk');
      expect(firstSprite, isNotNull);
      expect(firstSprite!.srcSize.x, greaterThan(0));
      expect(firstSprite.srcSize.y, greaterThan(0));
      expect(firstSprite.srcPosition, isNotNull);
    });

    test('throws exception for invalid atlas path', () async {
      final flameGame = FlameGame();
      expect(
        () => flameGame.atlasFromStorage('invalid_path.atlas'),
        throwsException,
      );
    });

    test('only loads whitelisted path matches', () async {
      final flameGame = FlameGame();
      final atlas = await flameGame.atlasFromStorage(
        atlasWhitelistPath,
        whiteList: ['junk-1'],
      );

      expect(atlas, isNotNull);
      expect(atlas.sprites.length, equals(2));

      final firstSprite = atlas.findSpriteByName('junk-1_layer0');
      expect(firstSprite, isNotNull);
      expect(firstSprite!.srcSize, isNotNull);
      expect(firstSprite.srcPosition, isNotNull);

      final secondSprite = atlas.findSpriteByName('junk-2_layer0');
      expect(secondSprite, isNull);
    });

    test('generates region data', () async {
      final regions = await TexturePackerAtlas.loadAtlas(
        atlasWhitelistPath,
        fromStorage: true,
      );

      expect(regions.regions, isNotEmpty);
      expect(regions.regions.length, equals(4));
    });
  });
}
