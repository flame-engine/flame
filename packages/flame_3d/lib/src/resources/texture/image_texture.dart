import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template image_texture}
/// A texture that holds an image as it's render-able texture.
/// {@endtemplate}
class ImageTexture(
  super.source, {
  required super.width,
  required super.height,
  super.sampler,
  super.mipmaps,
  super.gpuTexture,
}) extends Texture {
  /// Create a [ImageTexture] from the given [image], sampled with [sampler].
  ///
  /// Where the GPU backend can, the texture shares the image's GPU memory
  /// without copying it (on Flutter GPU, for images backed by a GPU texture:
  /// decoded images and those of the asynchronous `Picture.toImage`).
  /// Otherwise, and when [mipmaps] are asked for, the image's pixels are read
  /// back with `Image.toByteData` and uploaded.
  static Future<ImageTexture> create(
    Image image, {
    TextureSampler sampler = TextureSampler.nearest,
    bool mipmaps = false,
  }) async {
    final Image(:width, :height) = image;
    final wrapped = mipmaps ? null : _wrap(image);
    if (wrapped != null) {
      return ImageTexture(
        null,
        width: width,
        height: height,
        sampler: sampler,
        gpuTexture: wrapped,
      );
    }
    return ImageTexture(
      await image.toByteData(),
      width: width,
      height: height,
      sampler: sampler,
      mipmaps: mipmaps,
    );
  }

  static GpuTexture? _wrap(Image image) {
    if (!GpuBackend.isAvailable) {
      return null;
    }
    try {
      return GpuBackend.instance.createTextureFromImage(image);
    } on StateError {
      // The backend is not initialized yet (on the web).
      return null;
    }
  }
}
