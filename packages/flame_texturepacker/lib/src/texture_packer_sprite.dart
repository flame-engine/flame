import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flame_texturepacker/src/model/region.dart';

/// {@template _texture_packer_sprite}
/// A [Sprite] extracted from a texture packer file.
/// {@endtemplate}
class TexturePackerSprite extends Sprite {
  /// {@macro _texture_packer_sprite}
  TexturePackerSprite(Region region, {this.useOriginalSize = true})
      : _region = region,
        name = region.name,
        index = region.index,
        offsetX = region.offsetX,
        offsetY = region.offsetY,
        packedWidth = region.width,
        packedHeight = region.height,
        originalWidth = region.originalWidth,
        originalHeight = region.originalHeight,
        rotate = region.rotate,
        degrees = region.degrees,
        super(
          region.page.texture,
          srcPosition: Vector2(region.left, region.top),
          srcSize: Vector2(
            useOriginalSize ? region.originalWidth : region.width,
            useOriginalSize ? region.originalHeight : region.height,
          ),
        ) {
    if (region.rotate) {
      final transform = Transform2D()..angle = math.pi / 2;
      _decorator = Transform2DDecorator(transform);
    }
  }

  /// Region object for [clone] function, don't modify this object properties.
  final Region _region;

  /// If true, use [originalWidth] and [originalHeight] as size; otherwise use
  /// [packedWidth] and [packedHeight] as size.
  final bool useOriginalSize;

  /// The number at the end of the original image file name, or -1 if none.
  ///
  /// When sprites are packed, if the original file name ends with a number, it
  /// is stored as the index and is not considered as part of the sprite's name.
  /// This is useful for keeping animation frames in order.
  final int index;

  /// The name of the original image file, without the file's extension.
  /// If the name ends with an underscore followed by only numbers, that part is
  /// excluded: underscores denote special instructions to the texture packer.
  final String name;

  /// The offset from the left of the original image to the left of the packed
  /// image, after whitespace was removed for packing.
  final double offsetX;

  /// The offset from the bottom of the original image to the bottom of the
  /// packed image, after whitespace was removed for packing.
  final double offsetY;

  /// The width of the image, after whitespace was removed for packing.
  final double packedWidth;

  /// The height of the image, after whitespace was removed for packing.
  final double packedHeight;

  /// The width of the image, before whitespace was removed and rotation was
  /// applied for packing.
  final double originalWidth;

  /// The height of the image, before whitespace was removed for packing.
  final double originalHeight;

  /// If true, the region has been rotated 90 degrees counter clockwise.
  final bool rotate;

  /// The degrees the region has been rotated, counter clockwise between 0 and
  /// 359. Most atlas region handling deals only with 0 or 90 degree rotation
  /// (enough to handle rectangles).
  /// More advanced texture packing may support other rotations (eg, for tightly
  /// packing polygons).
  final int degrees;

  /// The [degrees] field (angle) represented as radians.
  double get angle => radians(degrees.toDouble());

  /// Clone current object with new value for argument [useOriginalSize].
  TexturePackerSprite clone({bool useOriginalSize = true}) =>
      TexturePackerSprite(_region, useOriginalSize: useOriginalSize);

  Vector2 get _srcSize => Vector2(src.width, src.height);

  Vector2 get _srcSizeRotated => Vector2(src.height, src.width);

  Vector2 get _srcSizeRender => rotate ? _srcSizeRotated : _srcSize;

  Vector2 get _offset => Vector2(offsetX, offsetY);

  Vector2 get _packedSize => Vector2(packedWidth, packedHeight);

  Vector2 get _originalSize => Vector2(originalWidth, originalHeight);

  Vector2 get offset => useOriginalSize ? _offset : Vector2.zero();

  @override
  Vector2 get originalSize => useOriginalSize ? _originalSize : _packedSize;

  @override
  Vector2 get srcSize => _srcSizeRender
    ..divide(_packedSize)
    ..multiply(originalSize);

  @override
  set srcSize(Vector2? size) {
    final actualSize = Vector2.copy(size ?? originalSize)
      ..divide(originalSize)
      ..multiply(_packedSize);
    if (rotate) {
      actualSize.setValues(actualSize.y, actualSize.x);
    }
    src = srcPosition.toPositionedRect(actualSize);
  }

  @override
  set srcPosition(Vector2? position) {
    src = (position ?? Vector2.zero()).toPositionedRect(_srcSize);
  }

  Decorator? _decorator;

  // Used to avoid the creation of new Vector2 objects in render.
  static final _tmpRenderPosition = Vector2.zero();
  static final _tmpRenderSize = Vector2.zero();
  static final _tmpRenderScale = Vector2.zero();
  static final _tmpRenderImageSize = Vector2.zero();
  static final _tmpRenderOffset = Vector2.zero();

  @override
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

    // Get sprite size
    _tmpRenderSize.setFrom(size ?? srcSize);

    // Calculate topLeft position
    _tmpRenderPosition.setValues(
      _tmpRenderPosition.x - (anchor.x * _tmpRenderSize.x),
      _tmpRenderPosition.y - (anchor.y * _tmpRenderSize.y),
    );

    // Calculate multiplier value
    _tmpRenderScale
      ..setFrom(_tmpRenderSize)
      ..divide(originalSize);

    // Calculate image size rendered based on packedSize
    _tmpRenderImageSize
      ..setFrom(_packedSize)
      ..multiply(_tmpRenderScale);

    // Calculate image rendered offset from topLeft position
    _tmpRenderOffset
      ..setFrom(offset)
      ..multiply(_tmpRenderScale)
      ..add(_tmpRenderPosition);

    if (!rotate) {
      // Calculate and render for non-rotated image, must call function render
      // from super class with anchor = Anchor.topLeft, because we already
      // calculated size and position based on Anchor.topLeft to rendered by
      // super class function.
      _tmpRenderSize.setFrom(_tmpRenderImageSize);
      _tmpRenderPosition.setFrom(_tmpRenderOffset);
      return super.render(
        canvas,
        position: _tmpRenderPosition,
        size: _tmpRenderSize,
        overridePaint: overridePaint,
      );
    }

    // Calculate and render for rotated image, must call function render
    // from super class with anchor = Anchor.topLeft, because we already
    // calculated size and position based on Anchor.topLeft to rendered by super
    // class function.
    _tmpRenderSize.setValues(_tmpRenderImageSize.y, _tmpRenderImageSize.x);
    _tmpRenderPosition.setValues(
      _tmpRenderOffset.y - 0,
      -_tmpRenderOffset.x - _tmpRenderImageSize.x,
    );

    _decorator?.applyChain(
      (applyCanvas) => super.render(
        applyCanvas,
        position: _tmpRenderPosition,
        size: _tmpRenderSize,
        overridePaint: overridePaint,
        bleed: bleed,
      ),
      canvas,
    );
  }
}
