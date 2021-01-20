import 'dart:async';
import 'dart:ui';

import 'package:flutter/painting.dart';

import 'assets/images.dart';
import 'extensions/rect.dart';
import 'extensions/vector2.dart';
import 'flame.dart';
import 'game/game.dart';

extension ParallaxExtension on Game {
  Future<Parallax> loadParallax(
    List<String> paths, {
    Vector2 baseVelocity,
    Vector2 velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
  }) {
    return Parallax.load(
      paths,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
    );
  }

  Future<ParallaxImage> loadParallaxImage(
    String path, {
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
  }) {
    return ParallaxImage.load(
      path,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
    );
  }

  Future<ParallaxLayer> loadParallaxLayer(
    String path, {
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Vector2 velocityMultiplier,
  }) {
    return ParallaxLayer.load(
      path,
      velocityMultiplier: velocityMultiplier,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
    );
  }
}

/// Specifications with a path to an image and how it should be drawn in
/// relation to the device screen
class ParallaxImage {
  /// The image
  final Image image;

  /// If and how the image should be repeated on the canvas
  final ImageRepeat repeat;

  /// How to align the image in relation to the screen
  final Alignment alignment;

  /// How to fill the screen with the image, always proportionally scaled.
  final LayerFill fill;

  ParallaxImage(
    this.image, {
    this.repeat = ImageRepeat.repeatX,
    this.alignment = Alignment.bottomLeft,
    this.fill = LayerFill.height,
  });

  /// Takes a path of an image, and optionally arguments for how the image should
  /// repeat ([repeat]), which edge it should align with ([alignment]), which axis
  /// it should fill the image on ([fill]) and [images] which is the image cache
  /// that should be used. If no image cache is set, the global flame cache is used.
  static Future<ParallaxImage> load(
    String path, {
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images images,
  }) async {
    images ??= Flame.images;
    return ParallaxImage(
      await images.load(path),
      repeat: repeat,
      alignment: alignment,
      fill: fill,
    );
  }
}

/// Represents one layer in the parallax, draws out an image on a canvas in the
/// manner specified by the parallaxImage
class ParallaxLayer {
  final ParallaxImage parallaxImage;
  Vector2 velocityMultiplier;
  Rect _paintArea;
  Vector2 _scroll;
  Vector2 _imageSize;
  double _scale = 1.0;

  /// [parallaxImage] is the representation of the image with data of how the
  /// image should behave.
  /// [velocityMultiplier] will be used to determine the velocity of the layer by
  /// multiplying the [baseVelocity] with the [velocityMultiplier].
  ParallaxLayer(
    this.parallaxImage, {
    Vector2 velocityMultiplier,
  }) : velocityMultiplier = velocityMultiplier ?? Vector2.all(1.0);

  Vector2 currentOffset() => _scroll;

  void resize(Vector2 size) {
    double scale(LayerFill fill) {
      switch (fill) {
        case LayerFill.height:
          return parallaxImage.image.height / size.y;
        case LayerFill.width:
          return parallaxImage.image.width / size.x;
        default:
          return _scale;
      }
    }

    _scale = scale(parallaxImage.fill);

    // The image size so that it fulfills the LayerFill parameter
    _imageSize = Vector2Extension.fromInts(
          parallaxImage.image.width,
          parallaxImage.image.height,
        ) /
        _scale;

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
    paintImage(
      canvas: canvas,
      image: parallaxImage.image,
      rect: _paintArea,
      repeat: parallaxImage.repeat,
      scale: _scale,
      alignment: parallaxImage.alignment,
    );
  }

  /// Takes a path of an image, and optionally arguments for how the image should
  /// repeat ([repeat]), which edge it should align with ([alignment]), which axis
  /// it should fill the image on ([fill]) and [images] which is the image cache
  /// that should be used. If no image cache is set, the global flame cache is used.
  static Future<ParallaxLayer> load(
    String path, {
    Vector2 velocityMultiplier,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images images,
  }) async {
    return ParallaxLayer(
      await ParallaxImage.load(
        path,
        repeat: repeat,
        alignment: alignment,
        fill: fill,
        images: images,
      ),
      velocityMultiplier: velocityMultiplier,
    );
  }
}

/// How to fill the screen with the image, always proportionally scaled.
enum LayerFill { height, width, none }

/// A full parallax, several layers of images drawn out on the screen and each
/// layer moves with different velocities to give an effect of depth.
class Parallax {
  Vector2 baseVelocity;
  final List<ParallaxLayer> layers;

  Parallax(
    this.layers, {
    Vector2 baseVelocity,
  }) : baseVelocity = baseVelocity ?? Vector2.zero();

  /// The base offset of the parallax, can be used in an outer update loop
  /// if you want to transition the parallax to a certain position.
  Vector2 currentOffset() => layers[0].currentOffset();

  /// If the `ParallaxComponent` isn't used your own wrapper needs to call this
  /// on creation.
  void resize(Vector2 size) => layers.forEach((layer) => layer.resize(size));

  void update(double t) {
    layers.forEach((layer) {
      layer.update(
        (baseVelocity.clone()..multiply(layer.velocityMultiplier)) * t,
      );
    });
  }

  /// Note that this method only should be used if all of your layers should
  /// have the same layer arguments (how the images should be repeated, aligned
  /// and filled), otherwise load the [ParallaxLayer]s individually and use the
  /// normal constructor.
  ///
  /// [load] takes a list of paths to all the images that you want to use in the
  /// parallax.
  /// Optionally arguments for the [baseVelocity] and [layerDelta] can be passed
  /// in, [baseVelocity] defines what the base velocity of the layers should be
  /// and [velocityMultiplierDelta] defines how the velocity should change the
  /// closer the layer is ([velocityMultiplierDelta ^ n], where n is the
  /// layer index).
  /// Arguments for how all the images should repeat ([repeat]),
  /// which edge it should align with ([alignment]), which axis it should fill
  /// the image on ([fill]) and [images] which is the image cache that should be
  /// used can also be passed in.
  /// If no image cache is set, the global flame cache is used.
  static Future<Parallax> load(
    List<String> paths, {
    Vector2 baseVelocity,
    Vector2 velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images images,
  }) async {
    velocityMultiplierDelta ??= Vector2.all(1.0);
    int depth = 0;
    final layers = await Future.wait<ParallaxLayer>(
      paths.map((path) async {
        final image = ParallaxImage.load(
          path,
          repeat: repeat,
          alignment: alignment,
          fill: fill,
          images: images,
        );
        final velocityMultiplier =
            List.filled(depth, velocityMultiplierDelta).fold<Vector2>(
          velocityMultiplierDelta,
          (previousValue, delta) => previousValue.clone()..multiply(delta),
        );
        ++depth;
        return ParallaxLayer(
          await image,
          velocityMultiplier: velocityMultiplier,
        );
      }),
    );
    return Parallax(
      layers,
      baseVelocity: baseVelocity,
    );
  }
}
