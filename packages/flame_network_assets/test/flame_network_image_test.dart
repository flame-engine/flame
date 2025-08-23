import 'dart:io';
import 'dart:ui';

import 'package:flame_network_assets/flame_network_assets.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;

abstract class __MockHttpClient {
  Future<FlameAssetResponse> get(
    String url, {
    Map<String, String>? headers,
  });
}

class _MockHttpClient extends Mock implements __MockHttpClient {}

abstract class __MockPathProvider {
  Future<Directory> getAppDirectory();
}

class _MockPathProvider extends Mock implements __MockPathProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlameNetworkAssets', () {
    late __MockHttpClient httpClient;
    late __MockPathProvider pathProvider;
    late Directory testDirectory;
    late FlameNetworkImages networkAssets;
    late Image image;

    setUpAll(() {
      testDirectory = Directory(
        path.join(
          Directory.systemTemp.path,
          'flame_network_assets_test',
        ),
      )..createSync();
    });

    tearDownAll(() {
      testDirectory.deleteSync(recursive: true);
    });

    setUp(() async {
      httpClient = _MockHttpClient();
      pathProvider = _MockPathProvider();

      when(pathProvider.getAppDirectory).thenAnswer((_) async => testDirectory);

      networkAssets = FlameNetworkImages(
        get: httpClient.get,
        getAppDirectory: pathProvider.getAppDirectory,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 50, 50),
        Paint()..color = Colors.pink,
      );
      final picture = recorder.endRecording();
      image = await picture.toImage(50, 50);

      final pngImage = await image.toByteData(format: ImageByteFormat.png);

      when(
        () => httpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async => FlameAssetResponse(
          statusCode: 200,
          bytes: pngImage!.buffer.asUint8List(),
        ),
      );
    });

    test('can be instantiated', () {
      expect(
        FlameNetworkImages(),
        isNotNull,
      );
    });

    test('returns the image', () async {
      const url = 'https://image1.com';
      final loadedImage = await networkAssets.load(url);
      expect(loadedImage, isA<Image>());
    });

    test('fetches the image in the network', () async {
      const url = 'https://image2.com';
      await networkAssets.load(url);
      verify(() => httpClient.get(url)).called(1);
    });

    test('returns the image from memory once it is cached', () async {
      const url = 'https://image3.com';
      final image1 = await networkAssets.load(url);
      final image2 = await networkAssets.load(url);

      verify(() => httpClient.get(url)).called(1);
      verify(pathProvider.getAppDirectory).called(2);

      expect(image1, equals(image2));
    });

    test('returns the image from local storage', () async {
      const url = 'https://image4.com';

      final image1 = await networkAssets.load(url);

      final secondNetworkAssets = FlameNetworkImages(
        getAppDirectory: pathProvider.getAppDirectory,
        get: httpClient.get,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final image2 = await secondNetworkAssets.load(url);

      verify(() => httpClient.get(url)).called(1);
      verify(pathProvider.getAppDirectory).called(3);

      expect(image1.width, equals(image2.width));
      expect(image1.height, equals(image2.height));
    });

    test('can still get the image if the local storage breaks', () async {
      const url = 'https://image5.com';

      final image1 = await networkAssets.load(url);

      final brokenPathProvider = _MockPathProvider();
      when(brokenPathProvider.getAppDirectory).thenThrow(Exception());
      final secondNetworkAssets = FlameNetworkImages(
        getAppDirectory: brokenPathProvider.getAppDirectory,
        get: httpClient.get,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final image2 = await secondNetworkAssets.load(url);

      verify(() => httpClient.get(url)).called(2);

      expect(image1.width, equals(image2.width));
      expect(image1.height, equals(image2.height));
    });

    test('does not cache in memory when cacheInMemory is false', () async {
      final secondNetworkAssets = FlameNetworkImages(
        getAppDirectory: pathProvider.getAppDirectory,
        get: httpClient.get,
        cacheInMemory: false,
      );
      const url = 'https://image6.com';
      final image1 = await secondNetworkAssets.load(url);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final image2 = await secondNetworkAssets.load(url);

      verify(() => httpClient.get(url)).called(1);
      verify(pathProvider.getAppDirectory).called(3);

      expect(image1.width, equals(image2.width));
      expect(image1.height, equals(image2.height));
    });

    test(
      'does not cache in local storage when cacheInMemory is false',
      () async {
        final secondNetworkAssets = FlameNetworkImages(
          getAppDirectory: pathProvider.getAppDirectory,
          get: httpClient.get,
          cacheInMemory: false,
          cacheInStorage: false,
        );
        const url = 'https://image7.com';
        final image1 = await secondNetworkAssets.load(url);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final image2 = await secondNetworkAssets.load(url);

        verify(() => httpClient.get(url)).called(2);
        verifyNever(pathProvider.getAppDirectory);

        expect(image1.width, equals(image2.width));
        expect(image1.height, equals(image2.height));
      },
    );
  });
}
