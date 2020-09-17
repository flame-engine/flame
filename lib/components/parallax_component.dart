import 'dart:async';
import 'dart:ui';

import 'package:flame/vector2f.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

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
  Vector2F _screenSize;
  Rect _paintArea;
  Vector2F _scroll;
  Vector2F _imageSize;
  double _scale = 1.0;

  ParallaxLayer(this.parallaxImage) {
    future = _load(parallaxImage.filename);
  }

  bool loaded() => _image != null;

  Vector2F currentOffset() => _scroll;

  void resize(Vector2F size) {
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
        Vector2F(_image.width.toDouble(), _image.height.toDouble()) / _scale;

    // Number of images that can fit on the canvas plus one
    // to have something to scroll to without leaving canvas empty
    final countX = 1 + size.x / _imageSize.x;
    final countY = 1 + size.y / _imageSize.y;

    // Percentage of the image size that will overflow
    final overflowX = (_imageSize.x * countX - size.x) / _imageSize.x;
    final overflowY = (_imageSize.y * countY - size.y) / _imageSize.y;

    // Align image to correct side of the screen
    final alignment = parallaxImage.alignment;
    final marginX = alignment.x == 0 ? overflowX / 2 : alignment.x;
    final marginY = alignment.y == 0 ? overflowY / 2 : alignment.y;
    _scroll ??= Vector2F(marginX, marginY);

    // Size of the area to paint the images on
    final paintSize = Vector2F(countX, countY)..multiply(_imageSize);
    _paintArea = paintSize.toRect();
  }

  void update(Vector2F delta) {
    if (!loaded()) {
      return;
    }

    // Scale the delta so that images that are larger don't scroll faster
    _scroll += delta..divide(_imageSize);
    switch (parallaxImage.repeat) {
      case ImageRepeat.repeat:
        _scroll = Vector2F(_scroll.x % 1, _scroll.y % 1);
        break;
      case ImageRepeat.repeatX:
        _scroll = Vector2F(_scroll.x % 1, _scroll.y);
        break;
      case ImageRepeat.repeatY:
        _scroll = Vector2F(_scroll.x, _scroll.y % 1);
        break;
      case ImageRepeat.noRepeat:
        break;
    }

    final dx = _scroll.x * _imageSize.x;
    final dy = _scroll.y * _imageSize.y;

    _paintArea = Rect.fromLTWH(-dx, -dy, _paintArea.width, _paintArea.height);
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

  Future<Image> _load(filename) {
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
  Vector2F baseSpeed;
  Vector2F layerDelta;
  List<ParallaxLayer> _layers;
  bool _loaded = false;

  ParallaxComponent(
    List<ParallaxImage> images, {
    this.baseSpeed,
    this.layerDelta,
  }) {
    baseSpeed ??= Vector2F.zero();
    layerDelta ??= Vector2F.zero();
    _load(images);
  }

  /// The base offset of the parallax, can be used in an outer update loop
  /// if you want to transition the parallax to a certain position.
  Vector2F currentOffset() => _layers[0].currentOffset();

  @override
  bool loaded() => _loaded;

  @mustCallSuper
  @override
  void resize(Vector2F size) {
    super.resize(size);
    _layers.forEach((layer) => layer.resize(size));
  }

  @override
  void update(double t) {
    super.update(t);
    if (!loaded()) {
      return;
    }
    _layers.forEach((layer) {
      layer.update(baseSpeed * t + layerDelta * (_layers.indexOf(layer) * t));
    });
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    if (!loaded()) {
      return;
    }

    super.render(canvas);

    canvas.save();
    _layers.forEach((layer) => layer.render(canvas));
    canvas.restore();
  }

  void _load(List<ParallaxImage> images) {
    _layers = images.map((image) => ParallaxLayer(image)).toList();
    Future.wait(_layers.map((layer) => layer.future))
        .then((_) => _loaded = true);
  }
}
