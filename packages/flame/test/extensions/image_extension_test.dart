import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final output = List.filled(8 * 8 * 4, 255);

void main() {
  group('ImageExtension', () {
    test('fromPixels', () async {
      final data = Uint8List(8 * 8 * 4);
      for (var i = 0; i < data.length; i += 4) {
        data[i] = 255;
        data[i + 1] = 255;
        data[i + 2] = 255;
        data[i + 3] = 255;
      }
      final image = await ImageExtension.fromPixels(data, 8, 8);
      final bytes = await image.toByteData();

      expect(bytes!.buffer.asUint8List(), equals(output));
    });

    test('pixelsInUint8', () async {
      final data = Uint8List(8 * 8 * 4);
      for (var i = 0; i < data.length; i += 4) {
        data[i] = 255;
        data[i + 1] = 255;
        data[i + 2] = 255;
        data[i + 3] = 255;
      }
      final image = await ImageExtension.fromPixels(data, 8, 8);
      expect(await image.pixelsInUint8(), equals(output));
    });

    testRandom('getBoundingRect', (Random r) async {
      final width = r.nextInt(4000);
      final height = r.nextInt(4000);
      final image = await createTestImage(width: width, height: height);
      final rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
      expect(image.getBoundingRect(), rect);
    });

    testRandom('size getter', (Random r) async {
      final width = r.nextInt(4000);
      final height = r.nextInt(4000);
      final image = await createTestImage(width: width, height: height);
      final size = Vector2(width.toDouble(), height.toDouble());
      expect(image.size, size);
    });

    test('darken colors each pixel darker', () async {
      const originalColor = Color.fromARGB(193, 135, 73, 73);
      final pixels = Uint8List.fromList(
        List<int>.generate(
          100 * 4,
          (index) {
            switch (index % 4) {
              case 0:
                return originalColor.red;
              case 1:
                return originalColor.green;
              case 2:
                return originalColor.blue;
              case 3:
                return originalColor.alpha;
              default:
                throw 'No 4 in switch % 4';
            }
          },
        ),
      );
      final image = await ImageExtension.fromPixels(pixels, 10, 10);

      const darkenAmount = 0.5;
      final originalDarkenImage = await image.darken(darkenAmount);
      final originalDarkenPixelsList =
          await originalDarkenImage.pixelsInUint8();

      final darkenColor = originalColor.darken(darkenAmount);
      final expectedDarkenPixels = Uint8List.fromList(
        List<int>.generate(
          100 * 4,
          (index) {
            switch (index % 4) {
              case 0:
                return darkenColor.red;
              case 1:
                return darkenColor.green;
              case 2:
                return darkenColor.blue;
              case 3:
                return darkenColor.alpha;
              default:
                throw 'No 4 in switch % 4';
            }
          },
        ),
      );
      expect(originalDarkenPixelsList, expectedDarkenPixels);
    });

    test('brighten colors each pixel brighter', () async {
      const originalColor = Color.fromARGB(193, 135, 73, 73);
      final pixels = Uint8List.fromList(
        List<int>.generate(
          100 * 4,
          (index) {
            switch (index % 4) {
              case 0:
                return originalColor.red;
              case 1:
                return originalColor.green;
              case 2:
                return originalColor.blue;
              case 3:
                return originalColor.alpha;
              default:
                throw 'No 4 in switch % 4';
            }
          },
        ),
      );
      final image = await ImageExtension.fromPixels(pixels, 10, 10);

      const brightenAmount = 0.5;
      final originalBrightenImage = await image.brighten(brightenAmount);
      final originalBrightenPixelsList =
          await originalBrightenImage.pixelsInUint8();

      final brightenColor = originalColor.brighten(brightenAmount);
      final expectedBrightenPixels = Uint8List.fromList(
        List<int>.generate(
          100 * 4,
          (index) {
            switch (index % 4) {
              case 0:
                return brightenColor.red;
              case 1:
                return brightenColor.green;
              case 2:
                return brightenColor.blue;
              case 3:
                return brightenColor.alpha;
              default:
                throw 'No 4 in switch % 4';
            }
          },
        ),
      );
      expect(originalBrightenPixelsList, expectedBrightenPixels);
    });

    test('resize resizes the image', () async {
      final recorder = PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 100, 100),
        Paint()..color = Colors.white,
      );
      final pic = recorder.endRecording();
      final image = await pic.toImage(100, 100);

      final resizedImage = await image.resize(Vector2(200, 400));
      expect(resizedImage.width, equals(200));
      expect(resizedImage.height, equals(400));
    });
  });
}
