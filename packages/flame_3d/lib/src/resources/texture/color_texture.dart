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
            List.filled(
              width * height,
              // Convert to a 32 bit value representing this color.
              ((color.a * 255.0).round() & 0xff) << 24 |
                  ((color.r * 255.0).round() & 0xff) << 16 |
                  ((color.g * 255.0).round() & 0xff) << 8 |
                  ((color.b * 255.0).round() & 0xff),
            ),
          ).buffer.asByteData(),
          width: width,
          height: height,
          format: PixelFormat.bgra8888,
        );
}
