import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/resources.dart';

class ColorTexture extends Texture {
  ColorTexture(Color color, {int width = 1, int height = 1})
      : super(
          Uint32List.fromList(
            List.filled(width * height, color.value),
          ).buffer.asByteData(),
          width: width,
          height: height,
          format: PixelFormat.bgra8888,
        );
}
