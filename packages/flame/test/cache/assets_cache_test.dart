import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../fixtures/fixture_reader.dart';

class _AssetsCacheMock extends Mock implements AssetsCache {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetsCache', () {
    test('readFile', () async {
      final assetsCache = AssetsCache(prefix: '');
      final fileName = fixture('test_text_file.txt').path;
      final file = await assetsCache.readFile(fileName);
      expect(file, isA<String>());

      expect(
        () async =>
            assetsCache.readBinaryFile(fixture('test_text_file.txt').path),
        failsAssert('"$fileName" was previously loaded as a text file'),
      );
    });

    test('readJson', () async {
      final assetsCache = AssetsCache(prefix: '');
      final file = await assetsCache.readJson(fixture('chopper.json').path);
      expect(file, isA<Map<String, dynamic>>());
    });

    test('readBinaryFile', () async {
      final assetsCache = AssetsCache(prefix: '');
      final fileName = fixture('caveace.fa').path;
      final file = await assetsCache.readBinaryFile(fileName);
      expect(file, isA<Uint8List>());

      expect(
        () async => assetsCache.readFile(fixture('caveace.fa').path),
        failsAssert('"$fileName" was previously loaded as a binary file'),
      );
    });

    test('clear', () async {
      final assetsCache = AssetsCache(prefix: '');

      final fileName = fixture('test_text_file.txt').path;
      final file = await assetsCache.readFile(fileName);
      expect(file, isA<String>());

      final assetsCacheMock = _AssetsCacheMock();
      assetsCacheMock.clear(fileName);
      verify(() => assetsCacheMock.clear(fileName)).called(1);
    });

    test('clearCache', () async {
      final assetsCache = AssetsCache(prefix: '');

      final fileName = fixture('test_text_file.txt').path;
      final file = await assetsCache.readFile(fileName);
      expect(file, isA<String>());

      final assetsCacheMock = _AssetsCacheMock();
      assetsCacheMock.clearCache();
      verify(assetsCacheMock.clearCache).called(1);

      // If all file was not clear from cache then it will not readBinaryFile
      assetsCache.clearCache();
      final fileTxtAsBinary = await assetsCache.readBinaryFile(fileName);
      expect(fileTxtAsBinary, isA<Uint8List>());
    });

    testWithFlameGame(
      'prefix on assets can not be changed',
      (game) async {
        game.assets = AssetsCache();
        expect(game.assets.prefix, 'assets/');
      },
    );

    testWithFlameGame(
      'Game.assets is same as Flame.assets',
      (game) async {
        expect(game.assets, equals(Flame.assets));
      },
    );
  });
}
