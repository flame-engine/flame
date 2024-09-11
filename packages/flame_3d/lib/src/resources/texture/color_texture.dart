import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/resources.dart';

/// {@template color_texture}
/// A texture that holds a single color. By default it creates a 1x1 texture.
/// {@endtemplate}
class ColorTexture extends Texture {
  /// {@macro color_texture}
  ColorTexture(Color color, {int width = 1, int height = 1})
      : super(
          Uint32List.fromList(
            // ignore: deprecated_member_use
            List.filled(width * height, color.value),
          ).buffer.asByteData(),
          width: width,
          height: height,
          format: PixelFormat.bgra8888,
        );
}
