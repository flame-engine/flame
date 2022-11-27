import 'dart:math';
import 'dart:typed_data';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
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
      const orignalColor = Color.fromARGB(193, 135, 73, 73);
      final pixels = Uint8List.fromList(
        List<int>.generate(
          100 * 4,
          (index) {
            switch (index % 4) {
              case 0:
                return orignalColor.red;
              case 1:
                return orignalColor.green;
              case 2:
                return orignalColor.blue;
              case 3:
                return orignalColor.alpha;
              default:
                throw 'No 4 in switch % 4';
            }
          },
        ),
      );
      final image = await ImageExtension.fromPixels(pixels, 10, 10);

      const darkenAmout = 0.5;
      final orignalDarkenImage = await image.darken(darkenAmout);
      final orignalDarkenPixelsList = await orignalDarkenImage.pixelsInUint8();

      final darkenColor = orignalColor.darken(darkenAmout);
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
      expect(orignalDarkenPixelsList, expectedDarkenPixels);
    });

    test('brighten colors each pixel brighter', () async {
      const orignalColor = Color.fromARGB(193, 135, 73, 73);
      final pixels = Uint8List.fromList(
        List<int>.generate(
          100 * 4,
          (index) {
            switch (index % 4) {
              case 0:
                return orignalColor.red;
              case 1:
                return orignalColor.green;
              case 2:
                return orignalColor.blue;
              case 3:
                return orignalColor.alpha;
              default:
                throw 'No 4 in switch % 4';
            }
          },
        ),
      );
      final image = await ImageExtension.fromPixels(pixels, 10, 10);

      const brightenAmout = 0.5;
      final orignalBrightenImage = await image.brighten(brightenAmout);
      final orignalBrightenPixelsList =
          await orignalBrightenImage.pixelsInUint8();

      final brightenColor = orignalColor.brighten(brightenAmout);
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
      expect(orignalBrightenPixelsList, expectedBrightenPixels);
    });
  });
}
