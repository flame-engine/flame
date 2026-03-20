import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:typled/typled.dart';

/// A sprite atlas backed by a [TypledAtlas].
///
/// Loads a Typled atlas definition and its associated image, applying
/// edge-repeated padding to eliminate "ghost lines" caused by
/// floating-point texture sampling errors.
class TypledSpriteAtlas {
  /// The parsed Typled atlas definition.
  final TypledAtlas atlas;

  /// The tile size in pixels.
  final double tileSize;

  /// The atlas image (padded or original depending on configuration).
  final Image image;

  /// Padding added around each tile in the atlas (1px per side,
  /// or 0 if padding is disabled).
  final int padding;

  /// Creates a [TypledSpriteAtlas] from a pre-loaded [atlas] and [image].
  TypledSpriteAtlas({
    required this.atlas,
    required this.tileSize,
    required this.image,
    required this.padding,
  });

  /// Creates a [SpriteBatch] from this atlas image.
  SpriteBatch toBatch({bool useAtlas = false}) {
    return SpriteBatch(image, useAtlas: useAtlas);
  }

  /// Returns a [Sprite] for the given [spriteId].
  ///
  /// Throws an [Exception] if the sprite is not found in the atlas.
  Sprite sprite(String spriteId) {
    final spriteData = atlas.sprites[spriteId];
    if (spriteData == null) {
      throw Exception('Sprite $spriteId not found in the atlas');
    }

    final paddedTileSize = tileSize + padding;
    final srcPosition = Vector2(
      spriteData.$1 * paddedTileSize + padding / 2,
      spriteData.$2 * paddedTileSize + padding / 2,
    );

    final srcSize = Vector2(
      (spriteData.$3 ?? 1) * tileSize,
      (spriteData.$4 ?? 1) * tileSize,
    );

    return Sprite(
      image,
      srcPosition: srcPosition,
      srcSize: srcSize,
    );
  }

  /// Loads a [TypledSpriteAtlas] from the given asset [path].
  ///
  /// When [disablePadding] is `true`, the original image is used as-is
  /// without edge-repeated padding.
  static Future<TypledSpriteAtlas> load(
    String path, {
    AssetsCache? cache,
    bool disablePadding = false,
  }) async {
    final atlas = await _loadAtlas(path, cache: cache);
    final originalImage = await Flame.images.load(atlas.imagePath);
    const padding = 2;
    final image = disablePadding
        ? originalImage
        : await _createPaddedAtlas(originalImage, atlas.tileSize, padding);
    return TypledSpriteAtlas(
      atlas: atlas,
      tileSize: atlas.tileSize.toDouble(),
      image: image,
      padding: disablePadding ? 0 : padding,
    );
  }

  /// Creates a new atlas image with edge-repeated padding around each tile.
  ///
  /// This eliminates "ghost lines" caused by floating-point rounding errors
  /// in texture sampling. Instead of transparent spacing, each tile's edge
  /// pixels are repeated into the padding so rounding errors sample a
  /// repeated pixel rather than transparency or a neighbor.
  static Future<Image> _createPaddedAtlas(
    Image original,
    int tileSize,
    int padding,
  ) async {
    final cols = original.width ~/ tileSize;
    final rows = original.height ~/ tileSize;
    final paddedTileSize = tileSize + padding;
    final halfPad = padding ~/ 2;

    final newWidth = cols * paddedTileSize;
    final newHeight = rows * paddedTileSize;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final srcX = (col * tileSize).toDouble();
        final srcY = (row * tileSize).toDouble();
        final dstX = (col * paddedTileSize + halfPad).toDouble();
        final dstY = (row * paddedTileSize + halfPad).toDouble();
        final ts = tileSize.toDouble();
        final hp = halfPad.toDouble();

        // Draw the main tile content
        canvas.drawImageRect(
          original,
          Rect.fromLTWH(srcX, srcY, ts, ts),
          Rect.fromLTWH(dstX, dstY, ts, ts),
          paint,
        );

        // Repeat left edge
        canvas.drawImageRect(
          original,
          Rect.fromLTWH(srcX, srcY, 1, ts),
          Rect.fromLTWH(dstX - hp, dstY, hp, ts),
          paint,
        );

        // Repeat right edge
        canvas.drawImageRect(
          original,
          Rect.fromLTWH(srcX + ts - 1, srcY, 1, ts),
          Rect.fromLTWH(dstX + ts, dstY, hp, ts),
          paint,
        );

        // Repeat top edge
        canvas.drawImageRect(
          original,
          Rect.fromLTWH(srcX, srcY, ts, 1),
          Rect.fromLTWH(dstX, dstY - hp, ts, hp),
          paint,
        );

        // Repeat bottom edge
        canvas.drawImageRect(
          original,
          Rect.fromLTWH(srcX, srcY + ts - 1, ts, 1),
          Rect.fromLTWH(dstX, dstY + ts, ts, hp),
          paint,
        );

        // Repeat corners (top-left, top-right, bottom-left, bottom-right)
        canvas.drawImageRect(
          original,
          Rect.fromLTWH(srcX, srcY, 1, 1),
          Rect.fromLTWH(dstX - hp, dstY - hp, hp, hp),
          paint,
        );
        canvas.drawImageRect(
          original,
          Rect.fromLTWH(srcX + ts - 1, srcY, 1, 1),
          Rect.fromLTWH(dstX + ts, dstY - hp, hp, hp),
          paint,
        );
        canvas.drawImageRect(
          original,
          Rect.fromLTWH(srcX, srcY + ts - 1, 1, 1),
          Rect.fromLTWH(dstX - hp, dstY + ts, hp, hp),
          paint,
        );
        canvas.drawImageRect(
          original,
          Rect.fromLTWH(srcX + ts - 1, srcY + ts - 1, 1, 1),
          Rect.fromLTWH(dstX + ts, dstY + ts, hp, hp),
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    return picture.toImage(newWidth, newHeight);
  }

  static Future<TypledAtlas> _loadAtlas(
    String path, {
    AssetsCache? cache,
  }) async {
    return TypledAtlas.parse(await (cache ?? Flame.assets).readFile(path));
  }
}

/// Extension on [Game] to provide convenience methods for loading
/// a [TypledSpriteAtlas].
extension TypledSpriteAtlasGameExtension on Game {
  /// Loads a [TypledSpriteAtlas] from the given asset [path].
  ///
  /// When [disablePadding] is `true`, the original image is used as-is
  /// without edge-repeated padding.
  Future<TypledSpriteAtlas> loadTypledAtlas(
    String path, {
    bool disablePadding = false,
  }) async {
    return TypledSpriteAtlas.load(
      path,
      cache: assets,
      disablePadding: disablePadding,
    );
  }
}
