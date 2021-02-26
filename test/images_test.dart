import 'dart:typed_data';

import 'package:flame/flame.dart';
import 'package:test/test.dart';

final output = List.filled(8 * 8 * 4, 255);

void main() {
  group('Images test', () {
    test('decodeImageFromPixels as native', () async {
      final data = Uint8List(8 * 8 * 4);
      for (var i = 0; i < data.length; i += 4) {
        data[i] = 255;
        data[i + 1] = 255;
        data[i + 2] = 255;
        data[i + 3] = 255;
      }
      final image = await Flame.images.decodeImageFromPixels(
        data,
        8,
        8,
        // ignore: avoid_redundant_argument_values
        runAsWeb: false, // default value is kIsWeb
      );

      expect((await image.toByteData())!.buffer.asUint8List(), equals(output));
    });

    test('decodeImageFromPixels as web', () async {
      final data = Uint8List(8 * 8 * 4);
      for (var i = 0; i < data.length; i += 4) {
        data[i] = 255;
        data[i + 1] = 255;
        data[i + 2] = 255;
        data[i + 3] = 255;
      }
      final image = await Flame.images.decodeImageFromPixels(
        data,
        8,
        8,
        // ignore: avoid_redundant_argument_values
        runAsWeb: true, // default value is kIsWeb
      );

      expect((await image.toByteData())!.buffer.asUint8List(), equals(output));
    });
  });
}
