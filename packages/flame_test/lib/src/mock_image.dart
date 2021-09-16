import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/flame.dart';

Future<Image> generateImage() {
  final data = Uint8List(4);
  for (var i = 0; i < data.length; i += 4) {
    data[i] = 255;
    data[i + 1] = 255;
    data[i + 2] = 255;
    data[i + 3] = 255;
  }
  return Flame.images.decodeImageFromPixels(data, 1, 1);
}
