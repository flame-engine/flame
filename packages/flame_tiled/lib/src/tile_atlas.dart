import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/src/rectangle_bin_packer.dart';
import 'package:flutter/foundation.dart';
import 'package:tiled/tiled.dart';

/// One image atlas for all Tiled image sets in a map.
///
/// Please note that [TiledAtlas] should not be reused without [clone] as it may
/// have a different [batch] instance.
class TiledAtlas {
  /// Single atlas for all renders.
  // Retain this as SpriteBatch can dispose of the original image for flips.
  final Image? atlas;

  /// Map of all source images to their new offset.
  final Map<String, Offset> offsets;

  /// The single batch operation for this atlas.
  final SpriteBatch? batch;

  /// Image key for this atlas.
  final String key;

  /// Track one atlas for all images in the Tiled map.
  ///
  /// See [fromTiledMap] for asynchronous loading.
  TiledAtlas._({
    required this.atlas,
    required this.offsets,
    required this.key,
  }) : batch = atlas == null ? null : SpriteBatch(atlas, imageKey: key);

  /// Returns whether or not this atlas contains [source].
  bool contains(String? source) => offsets.containsKey(source);

  /// Create a new atlas from this object with the intent of getting a new
  /// [SpriteBatch].
  TiledAtlas clone() => TiledAtlas._(
        atlas: atlas?.clone(),
        offsets: offsets,
        key: key,
      );

  /// Maps of tilesets compiled to [TiledAtlas].
  ///
  /// This is recommended to be cleared on test setup. Otherwise it
  /// could lead to unexpected behavior.
  @visibleForTesting
  static final atlasMap = <String, TiledAtlas>{};

  @visibleForTesting
  static String atlasKey(Iterable<TiledImage> images) {
    if (images.length == 1) {
      return images.first.source!;
    }

    final files = ([...images.map((e) => e.source)]..sort()).join(',');
    return 'atlas{$files}';
  }

  /// Collect images that we'll use in tiles - exclude image layers.
  static Set<TiledImage> _onlyTileImages(TiledMap map) {
    final imageSet = <TiledImage>{};
    for (var i = 0; i < map.tilesets.length; ++i) {
      final image = map.tilesets[i].image;
      if (image?.source != null) {
        imageSet.add(image!);
      }
      for (var j = 0; j < map.tilesets[i].tiles.length; ++j) {
        final image = map.tilesets[i].tiles[j].image;
        if (image?.source != null) {
          imageSet.add(image!);
        }
      }
    }
    return imageSet;
  }

  /// Loads all the tileset images for the [map] into one [TiledAtlas].
  static Future<TiledAtlas> fromTiledMap(
    TiledMap map, {
    double? maxX,
    double? maxY,
    Images? images,
  }) async {
    final imageList = _onlyTileImages(map).toList();

    if (imageList.isEmpty) {
      // so this map has no tiles... Ok.
      return TiledAtlas._(
        atlas: null,
        offsets: {},
        key: 'atlas{empty}',
      );
    }

    final key = atlasKey(imageList);
    if (atlasMap.containsKey(key)) {
      return atlasMap[key]!.clone();
    }

    if (imageList.length == 1) {
      // The map contains one image, so its either an atlas already, or a
      // really boring map.
      final image = (await (images ?? Flame.images).load(key)).clone();

      // There could be a special case that a concurrent call to this method
      // passes the check `if (atlasMap.containsKey(key))` due to the async call
      // inside this block. So, instance should always be recreated within this
      // block to prevent unintended reuse.
      return atlasMap[key] = TiledAtlas._(
        atlas: image,
        offsets: {key: Offset.zero},
        key: key,
      );
    }

    /// Note: Chrome on Android has a maximum texture size of 4096x4096. kIsWeb
    /// is used to select the smaller texture and might overflow. Consider using
    /// smaller textures for web targets, or, pack your own atlas.
    final bin = RectangleBinPacker(
      maxX ?? (kIsWeb ? 4096 : 8192),
      maxY ?? (kIsWeb ? 4096 : 8192),
    );
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final offsetMap = <String, Offset>{};

    var pictureRect = Rect.zero;

    imageList.sort((b, a) {
      final height = a.height! - b.height!;
      return height != 0 ? height : a.width! - b.width!;
    });

    // parallelize the download of images.
    await Future.wait([
      ...imageList.map(
        (tiledImage) => (images ?? Flame.images).load(tiledImage.source!),
      ),
    ]);

    final emptyPaint = Paint();
    for (final tiledImage in imageList) {
      final image = await (images ?? Flame.images).load(tiledImage.source!);
      final rect = bin.pack(image.width.toDouble(), image.height.toDouble());

      pictureRect = pictureRect.expandToInclude(rect);

      final offset =
          offsetMap[tiledImage.source!] = Offset(rect.left, rect.top);

      canvas.drawImage(image, offset, emptyPaint);
    }
    final picture = recorder.endRecording();
    final image = await picture.toImageSafe(
      pictureRect.width.toInt(),
      pictureRect.height.toInt(),
    );
    (images ?? Flame.images).add(key, image);
    return atlasMap[key] = TiledAtlas._(
      atlas: image,
      offsets: offsetMap,
      key: key,
    );
  }

  /// Clears images cached in `TiledAtlas`
  ///
  /// If you called `Flame.images.clearCache()` you also need to call this
  /// function to clear disposed images from tiled cache.
  static void clearCache() {
    atlasMap.clear();
  }
}
