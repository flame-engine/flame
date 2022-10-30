import 'dart:ui';

extension PictureExtension on Picture {
  /// Converts [Picture] into an [Image] and disposes of the picture.
  Future<Image> toImageSafe(int width, int height) {
    return toImage(width, height).then((image) {
      dispose();
      return image;
    });
  }
}
