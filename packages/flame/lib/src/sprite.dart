import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/cache/images.dart';
import 'package:flame/src/flame.dart';
import 'package:flame/src/image_composition.dart';
import 'package:flame/src/palette.dart';

/// A [Sprite] is a region of an [Image] that can be rendered in the Canvas.
///
/// It might represent the entire image or be one of the pieces a spritesheet is
/// composed of. It holds a reference to the source image from which the region
/// is extracted, and the [src] rectangle is the portion inside that image that
/// is to be rendered (not to be confused with the `dest` rect, which is where
/// in the Canvas the sprite is rendered).
/// It also has a [paint] field that can be overwritten to apply a tint to this
/// [Sprite] (default is white, meaning no tint).
class Sprite {
  Paint paint = BasicPalette.white.paint();
  Image image;
  Rect src = Rect.zero;

  Sprite(
    this.image, {
    Vector2? srcPosition,
    Vector2? srcSize,
  }) {
    this.srcSize = srcSize;
    this.srcPosition = srcPosition;
  }

  /// Takes a path of an image, a [srcPosition] and [srcSize] and loads the
  /// sprite animation.
  /// When the [images] is omitted, the global [Flame.images] is used.
  static Future<Sprite> load(
    String src, {
    Vector2? srcPosition,
    Vector2? srcSize,
    Images? images,
  }) async {
    final imagesCache = images ?? Flame.images;
    final image = await imagesCache.load(src);
    return Sprite(image, srcPosition: srcPosition, srcSize: srcSize);
  }

  double get _imageWidth => image.width.toDouble();

  double get _imageHeight => image.height.toDouble();

  Vector2 get originalSize => Vector2(_imageWidth, _imageHeight);

  Vector2 get srcSize => Vector2(src.width, src.height);

  set srcSize(Vector2? size) {
    final actualSize = size ?? image.size;
    src = srcPosition.toPositionedRect(actualSize);
  }

  Vector2 get srcPosition => src.topLeft.toVector2();

  set srcPosition(Vector2? position) {
    src = (position ?? Vector2.zero()).toPositionedRect(srcSize);
  }

  String _createRasterizeCacheKey() {
    return '${image.hashCode}-${srcPosition.x}-'
        '${srcPosition.y}-${srcSize.x}-${srcSize.y}';
  }

  /// Returns a new [Sprite] where the image in memory is just the region
  /// defined by the original sprite.
  ///
  /// If the [images] argument is passed it will be used to cache the
  /// rasterized image, otherwise the global [Flame.images] will be used.
  /// If the [cacheKey] is passed in, that will be the key for the cached image,
  /// otherwise the hash code of the rasterized image will be used as the key.
  Future<Sprite> rasterize({String? cacheKey, Images? images}) async {
    final key = cacheKey ?? _createRasterizeCacheKey();

    final imagesCache = images ?? Flame.images;

    if (imagesCache.containsKey(key)) {
      final cachedImage = imagesCache.fromCache(key);
      return Sprite(
        cachedImage,
        srcSize: srcSize,
      );
    }

    final rasterizedImage = await toImage();
    imagesCache.add(key, rasterizedImage);

    return Sprite(
      rasterizedImage,
      srcSize: srcSize,
    );
  }

  /// Same as [render], but takes both the position and the size as a single
  /// [Rect].
  ///
  /// **Note**: only use this if you are already using [Rect]'s to represent
  /// both the position and dimension of your [Sprite]. If you are using
  /// [Vector2]s, prefer the other method.
  void renderRect(
    Canvas canvas,
    Rect rect, {
    Paint? overridePaint,
  }) {
    render(
      canvas,
      position: rect.topLeft.toVector2(),
      size: rect.size.toVector2(),
      overridePaint: overridePaint,
    );
  }

  // Used to avoid the creation of new Vector2 objects in render.
  static final _tmpRenderPosition = Vector2.zero();
  static final _tmpRenderSize = Vector2.zero();
  static final _zeroPosition = Vector2.zero();

  /// Renders this sprite onto the [canvas].
  ///
  /// * [position]: x,y coordinates where it will be drawn; default to origin.
  /// * [size]: width/height dimensions; it can be bigger or smaller than the
  ///   original size -- but it defaults to the original texture size.
  /// * [anchor]: where in the sprite the x/y coordinates refer to; defaults to
  ///   topLeft.
  /// * [overridePaint]: paint to use. You can also change the paint on your
  ///   Sprite instance. Default is white.
  void render(
    Canvas canvas, {
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.topLeft,
    Paint? overridePaint,
    double? bleed,
  }) {
    if (position != null) {
      _tmpRenderPosition.setFrom(position);
    } else {
      _tmpRenderPosition.setZero();
    }

    _tmpRenderSize.setFrom(size ?? srcSize);

    _tmpRenderPosition.setValues(
      _tmpRenderPosition.x - (anchor.x * _tmpRenderSize.x),
      _tmpRenderPosition.y - (anchor.y * _tmpRenderSize.y),
    );

    if (bleed != null) {
      _tmpRenderPosition.x -= bleed;
      _tmpRenderPosition.y -= bleed;
      _tmpRenderSize.x += bleed * 2;
      _tmpRenderSize.y += bleed * 2;
    }

    final drawRect = _tmpRenderPosition.toPositionedRect(_tmpRenderSize);
    final drawPaint = overridePaint ?? paint;

    canvas.drawImageRect(image, src, drawRect, drawPaint);
  }

  /// Return a new [Image] based on the [src] of the Sprite.
  ///
  /// **Note:** This is a heavy async operation and should not be called inside
  /// the game loop. Remember to call dispose on the [Image] object once you
  /// aren't going to use it anymore.
  Future<Image> toImage() {
    final composition = ImageComposition()
      ..add(image, _zeroPosition, source: src);
    return composition.compose();
  }

  /// Return a new [Image] based on the [src] of the Sprite.
  ///
  /// A sync version of the [toImage] function. Read [Picture.toImageSync] for a
  /// detailed description of possible benefits in performance.
  Image toImageSync() {
    final composition = ImageComposition()
      ..add(image, _zeroPosition, source: src);
    return composition.composeSync();
  }
}
