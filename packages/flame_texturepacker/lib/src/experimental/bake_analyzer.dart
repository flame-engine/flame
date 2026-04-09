import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flame_texturepacker/src/experimental/atlas_decorator.dart';
import 'package:flame_texturepacker/src/experimental/bake_request.dart';
import 'package:meta/meta.dart';

@internal
class BakeInfo {
  final ui.Rect trimmedSrc;
  final double offsetX;
  final double offsetY;
  final double originalWidth;
  final double originalHeight;
  ui.Image? bakedImage;
  bool rotate;
  double? effectiveWidth;
  double? effectiveHeight;

  BakeInfo(
    this.trimmedSrc,
    this.offsetX,
    this.offsetY,
    this.originalWidth,
    this.originalHeight, {
    this.rotate = false,
    this.effectiveWidth,
    this.effectiveHeight,
  });
}

/// A internal record of a request to bake a sprite with specific settings.
@internal
class PendingBake {
  final Sprite sprite;
  final String prefix;
  final String name;
  final ui.ColorFilter? filter;
  final Decorator? decorator;
  final int? itemIndex;
  final int? itemCount;
  final RegionFilterKey bakeKey;
  final String? originalName;

  /// Explicit GDX source region (if provided).
  final SpriteSourceRegion? sourceRegion;

  PendingBake(
    this.sprite,
    this.prefix,
    this.name,
    this.filter,
    this.decorator,
    this.itemIndex,
    this.itemCount,
    this.bakeKey, {
    this.originalName,
    this.sourceRegion,
  });
}

@immutable
class RegionFilterKey {
  final ui.Image image;
  final ui.Rect src;
  final ui.ColorFilter? filter;
  final Decorator? decorator;
  final int? itemIndex;
  final int? itemCount;
  final double offsetX;
  final double offsetY;
  final double originalWidth;
  final double originalHeight;
  final bool rotate;

  const RegionFilterKey(
    this.image,
    this.src,
    this.filter,
    this.decorator,
    this.itemIndex,
    this.itemCount,
    this.offsetX,
    this.offsetY,
    this.originalWidth,
    this.originalHeight, {
    this.rotate = false,
  });

  double get width => src.width;
  double get height => src.height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegionFilterKey &&
          image == other.image &&
          src == other.src &&
          filter == other.filter &&
          decorator == other.decorator &&
          offsetX == other.offsetX &&
          offsetY == other.offsetY &&
          originalWidth == other.originalWidth &&
          originalHeight == other.originalHeight &&
          rotate == other.rotate &&
          (decorator is! AtlasDecorator ||
              (itemIndex == other.itemIndex && itemCount == other.itemCount)));

  @override
  int get hashCode => Object.hash(
    image,
    src,
    filter,
    decorator,
    offsetX,
    offsetY,
    originalWidth,
    originalHeight,
    rotate,
    decorator is AtlasDecorator ? Object.hash(itemIndex, itemCount) : null,
  );
}

class SpriteBakeInfo {
  final Sprite originalSprite;
  final ui.ColorFilter? filter;
  final Decorator? decorator;
  final String prefix;
  final String nameInAtlas;
  final ui.Rect trimmedSrc;
  final double offsetX;
  final double offsetY;
  final double originalWidth;
  final double originalHeight;
  final ui.Image? bakedImage;
  final int? itemIndex;
  final int? itemCount;
  final RegionFilterKey bakeKey;
  final bool rotate;

  SpriteBakeInfo({
    required this.originalSprite,
    required this.prefix,
    required this.nameInAtlas,
    required this.trimmedSrc,
    required this.offsetX,
    required this.offsetY,
    required this.originalWidth,
    required this.originalHeight,
    required this.bakeKey,
    this.filter,
    this.decorator,
    this.bakedImage,
    this.itemIndex,
    this.itemCount,
    this.rotate = false,
  });

  /// Analyzes a sprite to compute its non-transparent bounding box for
  /// trimming.
  ///
  /// The workflow:
  /// 1. Extract the source region (from explicit GDX rect or sprite.src)
  /// 2. If rotated, un-rotate into a temp buffer
  /// 3. Scan alpha channel to find tight non-transparent bounds
  /// 4. Compute GDX-style offsets relative to originalWidth/originalHeight
  static Future<SpriteBakeInfo> analyze({
    required RegionFilterKey key,
    required Sprite sprite,
    required ui.ColorFilter? filter,
    required Decorator? decorator,
    required String prefix,
    required String name,
    required int? itemIndex,
    required int? itemCount,
    SpriteSourceRegion? sourceRegion,
  }) async {
    try {
      // Determine source rect to analyze
      final scanSrc = sourceRegion?.toRect() ?? sprite.src;
      final origW = sourceRegion?.originalWidth ?? sprite.originalSize.x;
      final origH = sourceRegion?.originalHeight ?? sprite.originalSize.y;
      final isRotated =
          sourceRegion?.rotate ??
          (sprite is TexturePackerSprite && sprite.region.rotate);

      // Render the sprite into a temp buffer at its source size
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint()..filterQuality = ui.FilterQuality.none;
      if (filter != null) {
        paint.colorFilter = filter;
      }

      // Use visual (un-rotated) dimensions for packing.
      // GDX stores rotated sprites with swapped w/h in src.
      final visualW = isRotated ? scanSrc.height : scanSrc.width;
      final visualH = isRotated ? scanSrc.width : scanSrc.height;

      void draw(ui.Canvas c) {
        if (isRotated) {
          // Un-rotate: the source is 90° CCW, so we rotate 90° CW to un-rotate
          c.translate(visualW, 0);
          c.rotate(math.pi / 2);
        }

        // Draw the source region scaled to the render size
        c.drawImageRect(
          sprite.image,
          scanSrc,
          ui.Rect.fromLTWH(0, 0, scanSrc.width, scanSrc.height),
          paint,
        );
      }

      if (decorator != null) {
        if (decorator is AtlasDecorator) {
          (decorator as AtlasDecorator).updateAtlasContext(
            AtlasContext(
              atlasImage: sprite.image,
              srcRect: scanSrc,
              atlasSize: ui.Size(
                sprite.image.width.toDouble(),
                sprite.image.height.toDouble(),
              ),
              localSize: scanSrc.size,
              rotated: isRotated,
              itemIndex: itemIndex,
              itemCount: itemCount,
            ),
          );
        }
        decorator.applyChain(draw, canvas);
      } else {
        draw(canvas);
      }

      final tempImage = await recorder.endRecording().toImage(
        visualW.ceil(),
        visualH.ceil(),
      );

      // Scan alpha channel to find tight bounds
      final trimResult = await _scanAlpha(tempImage);

      ui.Rect trimmedSrc;
      double offsetX;
      double offsetY;

      if (trimResult != null) {
        // trimResult is relative to the tempImage
        // (un-rotated, visualW x visualH)
        trimmedSrc = trimResult.trimRect;
        // Final offset is the original sprite's offset PLUS the new trim offset
        offsetX = key.offsetX + trimResult.trimRect.left;
        offsetY = key.offsetY + trimResult.trimRect.top;
      } else {
        // Fully transparent - keep full size of the source region
        trimmedSrc = ui.Rect.fromLTWH(0, 0, visualW, visualH);
        offsetX = key.offsetX;
        offsetY = key.offsetY;
      }

      return SpriteBakeInfo(
        originalSprite: sprite,
        filter: filter,
        decorator: decorator,
        prefix: prefix,
        nameInAtlas: name,
        trimmedSrc: trimmedSrc,
        offsetX: offsetX,
        offsetY: offsetY,
        originalWidth: origW,
        originalHeight: origH,
        bakedImage: tempImage,
        itemIndex: itemIndex,
        itemCount: itemCount,
        bakeKey: key,
        rotate: isRotated,
      );
    } on Exception catch (e, stack) {
      final origW = sourceRegion?.originalWidth ?? sprite.originalSize.x;
      final origH = sourceRegion?.originalHeight ?? sprite.originalSize.y;
      return SpriteBakeInfo(
        originalSprite: sprite,
        filter: filter,
        prefix: prefix,
        nameInAtlas: name,
        trimmedSrc: sprite.src,
        offsetX: (sprite is TexturePackerSprite) ? sprite.region.offsetX : 0,
        offsetY: (sprite is TexturePackerSprite) ? sprite.region.offsetY : 0,
        originalWidth: origW,
        originalHeight: origH,
        itemIndex: itemIndex,
        itemCount: itemCount,
        bakeKey: key,
      );
    }
  }

  /// Scans an image's alpha channel and returns the tight non-transparent rect.
  /// Returns null if the image is fully transparent.
  /// Also returns a cropped image to save memory during packing.
  static Future<({ui.Rect trimRect, ui.Image croppedImage})?> _scanAlpha(
    ui.Image image,
  ) async {
    final byteData = await image.toByteData();
    if (byteData == null) {
      return null;
    }

    final buffer = byteData.buffer.asUint8List();
    final w = image.width;
    final h = image.height;

    var minX = w;
    var maxX = -1;
    var minY = h;
    var maxY = -1;
    var found = false;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final alpha = buffer[(y * w + x) * 4 + 3];
        if (alpha > 3) {
          if (x < minX) {
            minX = x;
          }
          if (x > maxX) {
            maxX = x;
          }
          if (y < minY) {
            minY = y;
          }
          if (y > maxY) {
            maxY = y;
          }
          found = true;
        }
      }
    }

    if (!found) {
      return null;
    }

    final trimRect = ui.Rect.fromLTRB(
      minX.toDouble(),
      minY.toDouble(),
      (maxX + 1).toDouble(),
      (maxY + 1).toDouble(),
    );

    // If already tight, no need to crop
    if (minX == 0 && minY == 0 && maxX == w - 1 && maxY == h - 1) {
      return (trimRect: trimRect, croppedImage: image);
    }

    // Crop to tight bounds
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      image,
      trimRect,
      ui.Rect.fromLTWH(0, 0, trimRect.width, trimRect.height),
      ui.Paint()..filterQuality = ui.FilterQuality.none,
    );
    final cropped = await recorder.endRecording().toImage(
      trimRect.width.toInt(),
      trimRect.height.toInt(),
    );

    return (trimRect: trimRect, croppedImage: cropped);
  }
}
