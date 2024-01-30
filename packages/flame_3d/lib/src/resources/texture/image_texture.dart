import 'dart:ui';

import 'package:flame_3d/resources.dart';

class ImageTexture extends Texture {
  ImageTexture(super.source, {required super.width, required super.height});

  static Future<Texture> create(Image image) async {
    final Image(:toByteData, :width, :height) = image;
    return ImageTexture((await toByteData())!, width: width, height: height);
  }
}
