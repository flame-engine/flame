import 'dart:ui';

import 'flame.dart';

class ImageAsset {
  Image image;
  VoidCallback _onLoad;

  ImageAsset(String file) {
    Flame.images.load(file).then((loadedImage) {
      image = loadedImage;
      _performOnLoad();
    });
  }

  ImageAsset.fromImage(this.image) {
    _performOnLoad();
  }

  void _performOnLoad() {
    _onLoad?.call();
    _onLoad = null;
  }

  void onLoad(VoidCallback onLoad) {
    if (loaded()) {
      onLoad?.call();
    } else {
      _onLoad = onLoad;
    }
  }

  bool loaded() => image != null;
}
