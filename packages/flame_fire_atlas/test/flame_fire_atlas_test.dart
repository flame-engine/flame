import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_fire_atlas/flame_fire_atlas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _AssetsCacheMock extends Mock implements AssetsCache {}

class _ImagesMock extends Mock implements Images {}

class _ImageMock extends Mock implements Image {}

class _MockedGame extends Mock implements FlameGame {
  final _imagesMock = _ImagesMock();
  @override
  Images get images => _imagesMock;

  final _assetsMock = _AssetsCacheMock();
  @override
  AssetsCache get assets => _assetsMock;
}

Future<Uint8List> _readTestFile() async {
  final exampleAtlas = File('./example/assets/cave_ace.fa');
  final bytes = await exampleAtlas.readAsBytes();
  return bytes;
}

Future<FireAtlas> _readTestAtlas() async {
  final assetsMock = _AssetsCacheMock();

  when(() => assetsMock.readBinaryFile('cave.fa')).thenAnswer((_) async {
    return _readTestFile();
  });

  final imagesMock = _ImagesMock();

  when(() => imagesMock.fromBase64(any(), any())).thenAnswer((_) async {
    return _ImageMock();
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
      final atlas = await _readTestAtlas();
      expect(atlas.id, 'cave_ace');
    });

    test('can load the asset using the global assets/images', () async {
      final assetsMock = _AssetsCacheMock();

      when(() => assetsMock.readBinaryFile('cave.fa')).thenAnswer((_) async {
        return _readTestFile();
      });

      final imagesMock = _ImagesMock();

      when(() => imagesMock.fromBase64(any(), any())).thenAnswer((_) async {
        return _ImageMock();
      });

      Flame.images = imagesMock;
      Flame.assets = assetsMock;

      await FireAtlas.loadAsset('cave.fa');

      verify(() => Flame.assets.readBinaryFile(any())).called(1);
      verify(() => Flame.images.fromBase64(any(), any())).called(1);
    });

    test('returns a sprite', () async {
      final atlas = await _readTestAtlas();

      final bullet = atlas.getSprite('bullet');
      expect(bullet, isNotNull);
    });

    test('throws when there is not sprite for that id', () async {
      final atlas = await _readTestAtlas();

      expect(
        () => atlas.getSprite('bla'),
        throwsA(
          equals('There is no selection with the id "bla" on this atlas'),
        ),
      );
    });

    test('throws when getSprite is used for an animation selection', () async {
      final atlas = await _readTestAtlas();

      expect(
        () => atlas.getSprite('bomb_ptero'),
        throwsA(equals('Selection "bomb_ptero" is not a Sprite')),
      );
    });

    test('returns an animation', () async {
      final atlas = await _readTestAtlas();
      final bombPtero = atlas.getAnimation('bomb_ptero');
      expect(bombPtero, isNotNull);
    });

    test('throws when there is not an animation for that id', () async {
      final atlas = await _readTestAtlas();

      expect(
        () => atlas.getAnimation('bla'),
        throwsA(
          equals('There is no selection with the id "bla" on this atlas'),
        ),
      );
    });

    test('throws when getAnimation is used for a sprite selection', () async {
      final atlas = await _readTestAtlas();

      expect(
        () => atlas.getAnimation('bullet'),
        throwsA(equals('Selection "bullet" is not an Animation')),
      );
    });

    test('converts to json', () async {
      final atlas = await _readTestAtlas();
      final json = atlas.toJson();
      expect(json['id'], 'cave_ace');
    });

    test('serialize/deserialize', () async {
      final atlas = await _readTestAtlas();

      final bytes = atlas.serialize();

      final copy = FireAtlas.deserializeBytes(bytes);
      expect(copy.id, atlas.id);
    });

    test(
      'Uses the game images and assets when loading from the game',
      () async {
        final game = _MockedGame();

        when(() => game.assets.readBinaryFile('cave.fa')).thenAnswer((_) async {
          return _readTestFile();
        });

        when(() => game.images.fromBase64(any(), any())).thenAnswer((_) async {
          return _ImageMock();
        });

        await game.loadFireAtlas('cave.fa');

        verify(() => game.assets.readBinaryFile(any())).called(1);
        verify(() => game.images.fromBase64(any(), any())).called(1);
      },
    );
  });
}
