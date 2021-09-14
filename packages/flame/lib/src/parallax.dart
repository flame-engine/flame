import 'dart:async';
import 'dart:ui';

import 'package:flutter/painting.dart';

import '../game.dart';
import 'assets/images.dart';
import 'extensions/canvas.dart';
import 'extensions/image.dart';
import 'extensions/rect.dart';
import 'extensions/vector2.dart';
import 'flame.dart';
import 'sprite_animation.dart';

extension ParallaxExtension on Game {
  Future<Parallax> loadParallax(
    List<ParallaxData> dataList, {
    Vector2? size,
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
  }) {
    return Parallax.load(
      dataList,
      size: size,
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

  Future<ParallaxAnimation> loadParallaxAnimation(
    String path,
    SpriteAnimationData animaitonData, {
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
  }) {
    return ParallaxAnimation.load(
      path,
      animaitonData,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
    );
  }

  Future<ParallaxLayer> loadParallaxLayer(
    ParallaxData data, {
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Vector2? velocityMultiplier,
  }) {
    return ParallaxLayer.load(
      data,
      velocityMultiplier: velocityMultiplier,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
    );
  }
}

abstract class ParallaxRenderer {
  /// If and how the image should be repeated on the canvas
  final ImageRepeat repeat;

  /// How to align the image in relation to the screen
  final Alignment alignment;

  /// How to fill the screen with the image, always proportionally scaled.
  final LayerFill fill;

  ParallaxRenderer({
    ImageRepeat? repeat,
    Alignment? alignment,
    LayerFill? fill,
  })  : repeat = repeat ?? ImageRepeat.repeatX,
        alignment = alignment ?? Alignment.bottomLeft,
        fill = fill ?? LayerFill.height;

  void update(double dt);
  Image get image;
}

/// Specifications with a path to an image and how it should be drawn in
/// relation to the device screen
class ParallaxImage extends ParallaxRenderer {
  /// The image
  final Image _image;

  ParallaxImage(
    this._image, {
    ImageRepeat? repeat,
    Alignment? alignment,
    LayerFill? fill,
  }) : super(
          repeat: repeat,
          alignment: alignment,
          fill: fill,
        );

  /// Takes a path of an image, and optionally arguments for how the image should
  /// repeat ([repeat]), which edge it should align with ([alignment]), which axis
  /// it should fill the image on ([fill]) and [images] which is the image cache
  /// that should be used. If no image cache is set, the global flame cache is used.
  static Future<ParallaxImage> load(
    String path, {
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
  }) async {
    images ??= Flame.images;
    return ParallaxImage(
      await images.load(path),
      repeat: repeat,
      alignment: alignment,
      fill: fill,
    );
  }

  @override
  Image get image => _image;

  @override
  void update(_) {
    // noop
  }
}

/// Specifications with a SpriteAnimation and how it should be drawn in
/// relation to the device screen
class ParallaxAnimation extends ParallaxRenderer {
  /// The Animation
  final SpriteAnimation _animation;

  /// The animation's frames prerended into images so it can be used in the parallax
  final List<Image> _prerenderedFrames;

  ParallaxAnimation(
    this._animation,
    this._prerenderedFrames, {
    ImageRepeat? repeat,
    Alignment? alignment,
    LayerFill? fill,
  }) : super(
          repeat: repeat,
          alignment: alignment,
          fill: fill,
        );

  /// Takes a path of an image, a SpriteAnimationData, and optionally arguments for how the image should
  /// repeat ([repeat]), which edge it should align with ([alignment]), which axis
  /// it should fill the image on ([fill]) and [images] which is the image cache
  /// that should be used. If no image cache is set, the global flame cache is used.
  ///
  /// _IMPORTANT_: This method pre render all the frames of the animation into image instances
  /// so it can be used inside the parallax. Just keep that in mind when using animations in
  /// in parallax, the over use of it, or the use of big animations (be it in number of frames
  /// or the size of the images) can lead to high use of memory.
  static Future<ParallaxAnimation> load(
    String path,
    SpriteAnimationData animationData, {
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
  }) async {
    images ??= Flame.images;

    final animation =
        await SpriteAnimation.load(path, animationData, images: images);
    final prerendedFrames = await Future.wait(
      animation.frames.map((frame) => frame.sprite.toImage()).toList(),
    );

    return ParallaxAnimation(
      animation,
      prerendedFrames,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
    );
  }

  @override
  Image get image => _prerenderedFrames[_animation.currentIndex];

  @override
  void update(double dt) {
    _animation.update(dt);
  }
}

/// Represents one layer in the parallax, draws out an image on a canvas in the
/// manner specified by the parallaxImage
class ParallaxLayer {
  final ParallaxRenderer parallaxRenderer;
  late Vector2 velocityMultiplier;
  late Rect _paintArea;
  late Vector2 _scroll;
  late Vector2 _imageSize;
  double _scale = 1.0;

  /// [parallaxRenderer] is the representation of the renderer with data of how the
  /// layer should behave.
  /// [velocityMultiplier] will be used to determine the velocity of the layer by
  /// multiplying the [Parallax.baseVelocity] with the [velocityMultiplier].
  ParallaxLayer(
    this.parallaxRenderer, {
    Vector2? velocityMultiplier,
  }) : velocityMultiplier = velocityMultiplier ?? Vector2.all(1.0);

  Vector2 currentOffset() => _scroll;

  void resize(Vector2 size) {
    double scale(LayerFill fill) {
      switch (fill) {
        case LayerFill.height:
          return parallaxRenderer.image.height / size.y;
        case LayerFill.width:
          return parallaxRenderer.image.width / size.x;
        default:
          return _scale;
      }
    }

    _scale = scale(parallaxRenderer.fill);

    // The image size so that it fulfills the LayerFill parameter
    _imageSize = parallaxRenderer.image.size / _scale;

    // Number of images that can fit on the canvas plus one
    // to have something to scroll to without leaving canvas empty
    final count = Vector2.all(1) + (size.clone()..divide(_imageSize));

    // Percentage of the image size that will overflow
    final overflow = ((_imageSize.clone()..multiply(count)) - size)
      ..divide(_imageSize);

    // Align image to correct side of the screen
    final alignment = parallaxRenderer.alignment;

    final marginX = alignment.x * overflow.x / 2 + overflow.x / 2;
    final marginY = alignment.y * overflow.y / 2 + overflow.y / 2;

    _scroll = Vector2(marginX, marginY);

    // Size of the area to paint the images on
    final paintSize = count..multiply(_imageSize);
    _paintArea = paintSize.toRect();
  }

  void update(Vector2 delta, double dt) {
    parallaxRenderer.update(dt);
    // Scale the delta so that images that are larger don't scroll faster
    _scroll += delta.clone()..divide(_imageSize);
    switch (parallaxRenderer.repeat) {
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

    final scrollPosition = _scroll.clone()..multiply(_imageSize);
    _paintArea = Rect.fromLTWH(
      -scrollPosition.x,
      -scrollPosition.y,
      _paintArea.width,
      _paintArea.height,
    );
  }

  void render(Canvas canvas) {
    if (_paintArea.isEmpty) {
      return;
    }
    paintImage(
      canvas: canvas,
      image: parallaxRenderer.image,
      rect: _paintArea,
      repeat: parallaxRenderer.repeat,
      scale: _scale,
      alignment: parallaxRenderer.alignment,
    );
  }

  /// Takes a data of a parallax renderer, and optionally arguments for how it should
  /// repeat ([repeat]), which edge it should align with ([alignment]), which axis
  /// it should fill the image on ([fill]) and [images] which is the image cache
  /// that should be used. If no image cache is set, the global flame cache is used.
  static Future<ParallaxLayer> load(
    ParallaxData data, {
    Vector2? velocityMultiplier,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
  }) async {
    return ParallaxLayer(
      await data.load(
        repeat,
        alignment,
        fill,
        images,
      ),
      velocityMultiplier: velocityMultiplier,
    );
  }
}

/// How to fill the screen with the image, always proportionally scaled.
enum LayerFill { height, width, none }

abstract class ParallaxData {
  Future<ParallaxRenderer> load(
    ImageRepeat repeat,
    Alignment alignment,
    LayerFill fill,
    Images? images,
  );
}

/// Contains the fields and logic to load a [ParallaxImage]
class ParallaxImageData extends ParallaxData {
  final String path;

  ParallaxImageData(this.path);

  @override
  Future<ParallaxRenderer> load(
    ImageRepeat repeat,
    Alignment alignment,
    LayerFill fill,
    Images? images,
  ) {
    return ParallaxImage.load(
      path,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
    );
  }
}

/// Contains the fields and logic to load a [ParallaxAnimation]
class ParallaxAnimationData extends ParallaxData {
  final String path;
  final SpriteAnimationData animationData;

  ParallaxAnimationData(this.path, this.animationData);

  @override
  Future<ParallaxRenderer> load(
    ImageRepeat repeat,
    Alignment alignment,
    LayerFill fill,
    Images? images,
  ) {
    return ParallaxAnimation.load(
      path,
      animationData,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
    );
  }
}

/// A full parallax, several layers of images drawn out on the screen and each
/// layer moves with different velocities to give an effect of depth.
class Parallax {
  late Vector2 baseVelocity;
  late Rect _clipRect;
  final List<ParallaxLayer> layers;

  bool isSized = false;
  late final Vector2 _size;

  /// Do not modify this directly, since the layers won't be resized if you do
  Vector2 get size => _size;
  set size(Vector2 newSize) {
    resize(newSize);
  }

  Parallax(
    this.layers, {
    Vector2? size,
    Vector2? baseVelocity,
  }) {
    this.baseVelocity = baseVelocity ?? Vector2.zero();
    if (size != null) {
      resize(size);
    }
  }

  /// The base offset of the parallax, can be used in an outer update loop
  /// if you want to transition the parallax to a certain position.
  Vector2 currentOffset() => layers[0].currentOffset();

  /// If the `ParallaxComponent` isn't used your own wrapper needs to call this
  /// on creation.
  void resize(Vector2 newSize) {
    if (!isSized) {
      _size = Vector2.zero();
    }
    if (newSize != _size || !isSized) {
      _size.setFrom(newSize);
      _clipRect = _size.toRect();
      layers.forEach((layer) => layer.resize(_size));
    }
    isSized |= true;
  }

  void update(double dt) {
    layers.forEach((layer) {
      layer.update(
        (baseVelocity.clone()..multiply(layer.velocityMultiplier)) * dt,
        dt,
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
  /// Optionally arguments for the [baseVelocity] and [velocityMultiplierDelta] can be passed
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
    List<ParallaxData> dataList, {
    Vector2? size,
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
  }) async {
    final velocityDelta = velocityMultiplierDelta ?? Vector2.all(1.0);
    var depth = 0;
    final layers = await Future.wait<ParallaxLayer>(
      dataList.map((data) async {
        final renderer = await data.load(
          repeat,
          alignment,
          fill,
          images,
        );
        final velocityMultiplier =
            List.filled(depth, velocityDelta).fold<Vector2>(
          velocityDelta,
          (previousValue, delta) => previousValue.clone()..multiply(delta),
        );
        ++depth;
        return ParallaxLayer(
          renderer,
          velocityMultiplier: velocityMultiplier,
        );
      }),
    );
    return Parallax(
      layers,
      size: size,
      baseVelocity: baseVelocity,
    );
  }

  void render(Canvas canvas, {Vector2? position}) {
    canvas.save();
    if (position != null) {
      canvas.translateVector(position);
    }
    canvas.clipRect(_clipRect);
    layers.forEach((layer) {
      canvas.save();
      layer.render(canvas);
      canvas.restore();
    });
    canvas.restore();
  }
}
