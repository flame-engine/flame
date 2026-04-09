import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flame_texturepacker/src/experimental/composite_atlas.dart'
    show CompositeAtlas;

/// Represents a request to bake assets into a [CompositeAtlas].
sealed class BakeRequest {
  final ui.ColorFilter? filter;
  final Decorator? decorator;
  final String? keyPrefix;

  /// A function that transforms the sprite name during baking.
  /// Useful for renaming mirrored sprites (e.g. '.right' -> '.left').
  final String Function(String name)? nameTransformer;

  BakeRequest({
    this.filter,
    this.decorator,
    this.keyPrefix,
    this.nameTransformer,
  });
}

/// Request to bake an entire [TexturePackerAtlas] (optionally filtered by
/// whitelist).
class AtlasBakeRequest extends BakeRequest {
  final TexturePackerAtlas atlas;
  final List<String>? whiteList;

  AtlasBakeRequest(
    this.atlas, {
    super.filter,
    super.decorator,
    super.keyPrefix,
    super.nameTransformer,
    this.whiteList,
  });
}

/// Describes the source region of a sprite with explicit GDX-style coordinates.
/// This avoids relying on [Sprite.srcPosition] which can be ambiguous.
class SpriteSourceRegion {
  /// X coordinate of the top-left corner in the source image.
  final double x;

  /// Y coordinate of the top-left corner in the source image.
  final double y;

  /// Width of the source region (packed/trimmed width from GDX).
  final double width;

  /// Height of the source region (packed/trimmed height from GDX).
  final double height;

  /// Original width before any trimming (the logical frame size).
  final double originalWidth;

  /// Original height before any trimming (the logical frame size).
  final double originalHeight;

  /// Whether this region is rotated 90° CCW in the source atlas.
  final bool rotate;

  const SpriteSourceRegion({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.originalWidth,
    required this.originalHeight,
    this.rotate = false,
  });

  ui.Rect toRect() => ui.Rect.fromLTWH(x, y, width, height);
}

/// Request to bake a standalone [Sprite] as a specific entry in the atlas.
///
/// When [sourceRegion] is provided, the sprite's pixel bounds are taken from
/// that explicit rect in the source image, and GDX-style offset computation
/// is used. This is the preferred way to bake sprites from a GDX atlas.
///
/// When [sourceRegion] is null, the sprite's own [Sprite.src] is used
/// (legacy behavior, suitable for spritesheets with uniform frames).
class SpriteBakeRequest extends BakeRequest {
  final Sprite sprite;
  final String name;

  /// Explicit GDX-style source region. When null, uses Sprite.src directly.
  final SpriteSourceRegion? sourceRegion;

  SpriteBakeRequest(
    this.sprite, {
    required this.name,
    super.filter,
    super.decorator,
    super.keyPrefix,
    super.nameTransformer,
    this.sourceRegion,
  });
}

/// Request to bake a raw [ui.Image] as a specific entry in the atlas.
class ImageBakeRequest extends BakeRequest {
  final ui.Image image;
  final String name;

  ImageBakeRequest(
    this.image, {
    required this.name,
    super.filter,
    super.decorator,
    super.keyPrefix,
    super.nameTransformer,
  });
}
