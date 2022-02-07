import 'dart:typed_data';

import 'package:flame/extensions.dart';

Future<Image> generateImage() {
  final data = Uint8List(4);
  for (var i = 0; i < data.length; i += 4) {
    data[i] = 255;
    data[i + 1] = 255;
    data[i + 2] = 255;
    data[i + 3] = 255;
  }
  return ImageExtension.fromPixels(data, 1, 1);
}
