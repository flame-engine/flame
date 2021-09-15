import 'dart:io';
import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_fire_atlas/flame_fire_atlas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class AssetsCacheMock extends Mock implements AssetsCache {}

class ImagesMock extends Mock implements Images {}

class ImageMock extends Mock implements Image {}

class MockedGame extends Mock implements FlameGame {
  final _imagesMock = ImagesMock();
  @override
  Images get images => _imagesMock;

  final _assetsMock = AssetsCacheMock();
  @override
  AssetsCache get assets => _assetsMock;
}

Future<List<int>> readExampleFile() async {
  final exampleAtlas = File('./example/assets/caveace.fa');
  final bytes = await exampleAtlas.readAsBytes();
  return bytes;
}

Future<FireAtlas> readTestAtlas() async {
  final assetsMock = AssetsCacheMock();

  when(() => assetsMock.readBinaryFile('cave.fa')).thenAnswer((_) async {
    return await readExampleFile();
  });

  final imagesMock = ImagesMock();

  when(() => imagesMock.fromBase64(any(), any())).thenAnswer((_) async {
    return ImageMock();
  });

  final atlas = await FireAtlas.loadAsset(
    'cave.fa',
    assets: assetsMock,
    images: imagesMock,
  );
  return atlas;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FireAtlas', () {
    test('can load the asset', () async {
      final atlas = await readTestAtlas();
      expect(atlas.id, 'caveace');
    });

    test('can load the asset using the global assets/images', () async {
      final assetsMock = AssetsCacheMock();

      when(() => assetsMock.readBinaryFile('cave.fa')).thenAnswer((_) async {
        return await readExampleFile();
      });

      final imagesMock = ImagesMock();

      when(() => imagesMock.fromBase64(any(), any())).thenAnswer((_) async {
        return ImageMock();
      });

      Flame.images = imagesMock;
      Flame.assets = assetsMock;

      await FireAtlas.loadAsset('cave.fa');

      verify(() => Flame.assets.readBinaryFile(any())).called(1);
      verify(() => Flame.images.fromBase64(any(), any())).called(1);
    });

    test('returns a sprite', () async {
      final atlas = await readTestAtlas();

      final bullet = atlas.getSprite('bullet');
      expect(bullet, isNotNull);
    });

    test('throws when there is not sprite for that id', () async {
      final atlas = await readTestAtlas();

      expect(
        () => atlas.getSprite('bla'),
        throwsA(
            equals('There is no selection with the id "bla" on this atlas')),
      );
    });

    test('throws when getSprite is used for an animation selection', () async {
      final atlas = await readTestAtlas();

      expect(
        () => atlas.getSprite('bomb_ptero'),
        throwsA(equals('Selection "bomb_ptero" is not a Sprite')),
      );
    });

    test('returns an animation', () async {
      final atlas = await readTestAtlas();
      final bombPtero = atlas.getAnimation('bomb_ptero');
      expect(bombPtero, isNotNull);
    });

    test('throws when there is not an animation for that id', () async {
      final atlas = await readTestAtlas();

      expect(
        () => atlas.getAnimation('bla'),
        throwsA(
            equals('There is no selection with the id "bla" on this atlas')),
      );
    });

    test('throws when getAnimation is used for a sprite selection', () async {
      final atlas = await readTestAtlas();

      expect(
        () => atlas.getAnimation('bullet'),
        throwsA(equals('Selection "bullet" is not an Animation')),
      );
    });

    test('converts to json', () async {
      final atlas = await readTestAtlas();
      final json = atlas.toJson();
      expect(json['id'], 'caveace');
    });

    test('serialize/deserialize', () async {
      final atlas = await readTestAtlas();

      final bytes = atlas.serialize();

      final copy = FireAtlas.deserialize(bytes);
      expect(copy.id, atlas.id);
    });

    test('Uses the game images and assets when loading from the game',
        () async {
      final game = MockedGame();

      when(() => game.assets.readBinaryFile('cave.fa')).thenAnswer((_) async {
        return await readExampleFile();
      });

      when(() => game.images.fromBase64(any(), any())).thenAnswer((_) async {
        return ImageMock();
      });

      await game.loadFireAtlas('cave.fa');

      verify(() => game.assets.readBinaryFile(any())).called(1);
      verify(() => game.images.fromBase64(any(), any())).called(1);
    });
  });
}
