import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flame_texturepacker/src/model/region.dart';
import 'package:flutter/material.dart';

/// {@template _texture_packer_sprite}
/// A [Sprite] extracted from a texture packer file.
/// {@endtemplate}
class TexturePackerSprite extends Sprite {
  /// {@macro _texture_packer_sprite}
  TexturePackerSprite(this.region, {this.useOriginalSize = true})
    : super(
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
    } else {
      _decorator = null;
    }
  }

  /// Region object for [clone] function, don't modify this object properties.
  final Region region;

  /// If true, use [Region.originalWidth] and [Region.originalHeight] as size;
  /// otherwise use [Region.width] and [Region.height] as size.
  final bool useOriginalSize;

  /// The [Region.degrees] field (angle) represented as radians.
  double get angle => radians(region.degrees.toDouble());

  /// Clone current object with new value for argument [useOriginalSize].
  TexturePackerSprite clone({bool useOriginalSize = true}) =>
      TexturePackerSprite(region, useOriginalSize: useOriginalSize);

  Vector2 get _srcSize => Vector2(src.width, src.height);

  Vector2 get _srcSizeRotated => Vector2(src.height, src.width);

  Vector2 get _srcSizeRender => region.rotate ? _srcSizeRotated : _srcSize;

  Vector2 get _offset => Vector2(region.offsetX, region.offsetY);

  Vector2 get _packedSize => Vector2(region.width, region.height);

  Vector2 get _originalSize => Vector2(
    region.originalWidth,
    region.originalHeight,
  );

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
    if (region.rotate) {
      actualSize.setValues(actualSize.y, actualSize.x);
    }
    src = srcPosition.toPositionedRect(actualSize);
  }

  @override
  set srcPosition(Vector2? position) {
    src = (position ?? Vector2.zero()).toPositionedRect(_srcSize);
  }

  late final Decorator? _decorator;

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

    if (!region.rotate) {
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
