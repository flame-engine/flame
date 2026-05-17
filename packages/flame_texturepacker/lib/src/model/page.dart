import 'dart:ui';

class Page {
  late String textureFile;
  Image? texture;
  late int width;
  late int height;
  late String format;
  late String minFilter;
  late String magFilter;
  String? repeat;

  /// Returns true if the texture has been loaded.
  bool get isLoaded => texture != null;
}
