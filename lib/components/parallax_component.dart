import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import '../flame.dart';
import 'position_component.dart';

/// Specifications with a path to an image and how it should be drawn in
/// relation to the device screen
class ParallaxImage {
  /// The filename of the image
  final String filename;

  /// If and how the image should be repeated on the canvas
  final ImageRepeat repeat;

  /// How to align the image in relation to the screen
  final Alignment alignment;

  /// How to fill the screen with the image, always proportionally scaled.
  final LayerFill fill;

  ParallaxImage(
    this.filename, {
    this.repeat = ImageRepeat.repeatX,
    this.alignment = Alignment.bottomLeft,
    this.fill = LayerFill.height,
  });
}

/// Represents one layer in the parallax, draws out an image on a canvas in the
/// manner specified by the parallaxImage
class ParallaxLayer {
  final ParallaxImage parallaxImage;
  Future<Image> future;

  Image _image;
  Rect _paintArea;
  Vector2 _screenSize;
  Vector2 _scroll;
  Vector2 _imageSize;
  double _scale = 1.0;

  ParallaxLayer(this.parallaxImage) {
    future = _load(parallaxImage.filename);
  }

  bool loaded() => _image != null;

  Vector2 currentOffset() => _scroll;

  void resize(Vector2 size) {
    if (!loaded()) {
      _screenSize = size;
      return;
    }

    double scale(LayerFill fill) {
      switch (fill) {
        case LayerFill.height:
          return _image.height / size.y;
        case LayerFill.width:
          return _image.width / size.x;
        default:
          return _scale;
      }
    }

    _scale = scale(parallaxImage.fill);

    // The image size so that it fulfills the LayerFill parameter
    _imageSize =
        Vector2Extension.fromInts(_image.width, _image.height) / _scale;

    // Number of images that can fit on the canvas plus one
    // to have something to scroll to without leaving canvas empty
    final Vector2 count = Vector2.all(1) + (size.clone()..divide(_imageSize));

    // Percentage of the image size that will overflow
    final Vector2 overflow = ((_imageSize.clone()..multiply(count)) - size)
      ..divide(_imageSize);

    // Align image to correct side of the screen
    final alignment = parallaxImage.alignment;
    final marginX = alignment.x == 0 ? overflow.x / 2 : alignment.x;
    final marginY = alignment.y == 0 ? overflow.y / 2 : alignment.y;
    _scroll ??= Vector2(marginX, marginY);

    // Size of the area to paint the images on
    final Vector2 paintSize = count..multiply(_imageSize);
    _paintArea = paintSize.toRect();
  }

  void update(Vector2 delta) {
    if (!loaded()) {
      return;
    }

    // Scale the delta so that images that are larger don't scroll faster
    _scroll += delta.clone()..divide(_imageSize);
    switch (parallaxImage.repeat) {
      case ImageRepeat.repeat:
        _scroll = Vector2(_scroll.x % 1, _scroll.y % 1);
        break;
      case ImageRepeat.repeatX:
        _scroll = Vector2(_scroll.x % 1, _scroll.y);
        break;
      case ImageRepeat.repeatY:
        _scroll = Vector2(_scroll.x, _scroll.y % 1);
        break;
      case ImageRepeat.noRepeat:
        break;
    }

    final Vector2 scrollPosition = _scroll.clone()..multiply(_imageSize);
    _paintArea = Rect.fromLTWH(
      -scrollPosition.x,
      -scrollPosition.y,
      _paintArea.width,
      _paintArea.height,
    );
  }

  void render(Canvas canvas) {
    if (!loaded()) {
      return;
    }

    paintImage(
      canvas: canvas,
      image: _image,
      rect: _paintArea,
      repeat: parallaxImage.repeat,
      scale: _scale,
      alignment: parallaxImage.alignment,
    );
  }

  Future<Image> _load(String filename) {
    return Flame.images.load(filename).then((image) {
      _image = image;
      if (_screenSize != null) {
        resize(_screenSize);
      }
      return _image;
    });
  }
}

/// How to fill the screen with the image, always proportionally scaled.
enum LayerFill { height, width, none }

/// A full parallax, several layers of images drawn out on the screen and each
/// layer moves with different speeds to give an effect of depth.
class ParallaxComponent extends PositionComponent {
  Vector2 baseSpeed;
  Vector2 layerDelta;
  List<ParallaxLayer> _layers;
  final List<ParallaxImage> _images;

  ParallaxComponent(
    this._images, {
    this.baseSpeed,
    this.layerDelta,
  }) {
    baseSpeed ??= Vector2.zero();
    layerDelta ??= Vector2.zero();
  }

  @override
  Future<void> onLoad() async {
    await _load(_images);
    _layers?.forEach((layer) => layer.resize(size));
  }

  /// The base offset of the parallax, can be used in an outer update loop
  /// if you want to transition the parallax to a certain position.
  Vector2 currentOffset() => _layers[0].currentOffset();

  @mustCallSuper
  @override
  void onGameResize(Vector2 size) {
    this.size = size;
    super.onGameResize(size);
    _layers?.forEach((layer) => layer.resize(size));
  }

  @override
  void update(double t) {
    super.update(t);
    _layers.forEach((layer) {
      layer.update(baseSpeed * t + layerDelta * (_layers.indexOf(layer) * t));
    });
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    _layers.forEach((layer) => layer.render(canvas));
    canvas.restore();
  }

  Future<void> _load(List<ParallaxImage> images) async {
    _layers = images.map((image) => ParallaxLayer(image)).toList();
    await Future.wait(_layers.map((layer) => layer.future));
  }
}
