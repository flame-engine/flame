import 'dart:io';
import 'dart:ui';

import 'package:flame_network_image/flame_network_image.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;

abstract class __MockHttpClient {
  Future<FlameImageResponse> get(
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

  group('FlameNetworkImages', () {
    late __MockHttpClient httpClient;
    late __MockPathProvider pathProvider;
    late Directory testDirectory;
    late FlameNetworkImages networkImages;
    late Image image;

    setUpAll(() {
      testDirectory = Directory(
        path.join(
          Directory.systemTemp.path,
          'flame_network_image_test',
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

      networkImages = FlameNetworkImages(
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

      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => FlameImageResponse(
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
      final loadedImage = await networkImages.load('https://image1.com');
      expect(loadedImage, isA<Image>());
    });
  });
}
