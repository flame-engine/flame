import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../fixtures/fixture_reader.dart';

class _MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetsCache', () {
    test('readFile', () async {
      final assetsCache = AssetsCache(prefix: '');
      final fileName = fixture('test_text_file.txt').path;
      final file = await assetsCache.readFile(fileName);
      expect(file, isA<String>());

      expect(
        () => assetsCache.readBinaryFile(fixture('test_text_file.txt').path),
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
      final fileName = fixture('cave_ace.fa').path;
      final file = await assetsCache.readBinaryFile(fileName);
      expect(file, isA<Uint8List>());

      expect(
        () => assetsCache.readFile(fixture('cave_ace.fa').path),
        failsAssert('"$fileName" was previously loaded as a binary file'),
      );
    });

    test('clear', () async {
      final assetsCache = AssetsCache(prefix: '');

      final fileName = fixture('test_text_file.txt').path;
      final file = await assetsCache.readFile(fileName);
      expect(file, isA<String>());

      assetsCache.clear(fileName);
      expect(assetsCache.cacheCount, equals(0));
    });

    test('clearCache', () async {
      final assetsCache = AssetsCache(prefix: '');

      final fileName = fixture('test_text_file.txt').path;
      final file = await assetsCache.readFile(fileName);
      expect(file, isA<String>());

      assetsCache.clearCache();
      expect(assetsCache.cacheCount, equals(0));
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

    test('bundle can be overridden', () async {
      final bundle = _MockAssetBundle();
      when(() => bundle.loadString(any())).thenAnswer((_) async => 'Two ducks');

      final cache = AssetsCache(bundle: bundle);

      final result = await cache.readFile('duck_count');
      expect(result, equals('Two ducks'));
      verify(() => bundle.loadString('assets/duck_count')).called(1);
    });
  });
}
