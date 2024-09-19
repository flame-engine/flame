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

    group('SpriteSelection', () {
      test('can be created from a json', () async {
        final sprite = SpriteSelection.fromJson({
          'id': 'kinetic_bullet',
          'x': 0,
          'y': 0,
          'w': 16,
          'h': 16,
          'group': 'bullets',
        });
        expect(sprite.id, 'kinetic_bullet');
        expect(sprite.x, 0);
        expect(sprite.y, 0);
        expect(sprite.w, 16);
        expect(sprite.h, 16);
        expect(sprite.group, 'bullets');
      });

      test('serializes to json', () async {
        final sprite = SpriteSelection(
          info: Selection(
            id: 'kinetic_bullet',
            x: 0,
            y: 0,
            w: 16,
            h: 16,
          ),
          group: 'bullets',
        );
        final json = sprite.toJson();
        expect(json['id'], 'kinetic_bullet');
        expect(json['x'], 0);
        expect(json['y'], 0);
        expect(json['w'], 16);
        expect(json['h'], 16);
        expect(json['group'], 'bullets');
      });

      group('copyWithGroup', () {
        test('creates a copy with a new group', () async {
          final sprite = SpriteSelection(
            info: Selection(
              id: 'kinetic_bullet',
              x: 0,
              y: 0,
              w: 16,
              h: 16,
            ),
            group: 'bullets',
          );

          final copy = sprite.copyWithGroup('new_group');
          expect(copy.group, 'new_group');
          expect(copy.id, 'kinetic_bullet');
          expect(copy.x, 0);
          expect(copy.y, 0);
          expect(copy.w, 16);
          expect(copy.h, 16);
        });
      });
    });

    group('AnimationSelection', () {
      test('can be created from a json', () async {
        final animation = AnimationSelection.fromJson({
          'id': 'bomb_ptero',
          'frameCount': 1,
          'stepTime': 0.2,
          'loop': true,
          'x': 0,
          'y': 0,
          'w': 16,
          'h': 16,
          'group': 'enemies',
        });

        expect(animation.id, 'bomb_ptero');
        expect(animation.frameCount, 1);
        expect(animation.stepTime, 0.2);
        expect(animation.loop, isTrue);
        expect(animation.x, 0);
        expect(animation.y, 0);
        expect(animation.w, 16);
        expect(animation.h, 16);
        expect(animation.group, 'enemies');
      });

      test('serializes to json', () async {
        final animation = AnimationSelection(
          info: Selection(
            id: 'bomb_ptero',
            x: 0,
            y: 0,
            w: 16,
            h: 16,
          ),
          frameCount: 1,
          stepTime: 0.2,
          loop: true,
          group: 'enemies',
        );
        final json = animation.toJson();
        expect(json['id'], 'bomb_ptero');
        expect(json['frameCount'], 1);
        expect(json['stepTime'], 0.2);
        expect(json['loop'], isTrue);
        expect(json['x'], 0);
        expect(json['y'], 0);
        expect(json['w'], 16);
        expect(json['h'], 16);
        expect(json['group'], 'enemies');
      });

      group('copyWithGroup', () {
        test('creates a copy with a new group', () async {
          final animation = AnimationSelection(
            info: Selection(
              id: 'bomb_ptero',
              x: 0,
              y: 0,
              w: 16,
              h: 16,
            ),
            frameCount: 1,
            stepTime: 0.2,
            loop: true,
            group: 'enemies',
          );

          final copy = animation.copyWithGroup('new_group');
          expect(copy.group, 'new_group');
          expect(copy.id, 'bomb_ptero');
          expect(copy.frameCount, 1);
          expect(copy.stepTime, 0.2);
          expect(copy.loop, isTrue);
          expect(copy.x, 0);
          expect(copy.y, 0);
          expect(copy.w, 16);
          expect(copy.h, 16);
        });
      });
    });
  });
}
