import 'dart:ui';

import 'package:flame_3d/resources.dart';

/// {@template image_texture}
/// A texture that holds an image as it's render-able texture.
/// {@endtemplate}
class ImageTexture(super.source, {required super.width, required super.height})
    extends Texture {
  /// Create a [ImageTexture] from the given [image].
  static Future<ImageTexture> create(Image image) async {
    final Image(:toByteData, :width, :height) = image;
    // Straight alpha: the shaders premultiply only what they blend.
    final bytes = await toByteData(format: ImageByteFormat.rawStraightRgba);
    return ImageTexture(bytes!, width: width, height: height);
  }
}
