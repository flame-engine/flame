import 'dart:ui';

import 'package:flame_3d/resources.dart';

/// {@template image_texture}
/// A texture that holds an image as it's render-able texture.
/// {@endtemplate}
class ImageTexture extends Texture {
  /// {@macro image_texture}
  ImageTexture(super.source, {required super.width, required super.height});

  /// Create a [ImageTexture] from the given [image].
  static Future<ImageTexture> create(Image image) async {
    final Image(:toByteData, :width, :height) = image;
    return ImageTexture((await toByteData())!, width: width, height: height);
  }
}
