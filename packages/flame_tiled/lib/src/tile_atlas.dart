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
  static Set<(String?, TiledImage)> _onlyTileImages(TiledMap map) {
    final imageSet = <(String?, TiledImage)>{};
    for (var i = 0; i < map.tilesets.length; ++i) {
      final tileset = map.tilesets[i];
      final image = tileset.image;
      if (image?.source != null) {
        imageSet.add((tileset.source, image!));
      }
      for (var j = 0; j < map.tilesets[i].tiles.length; ++j) {
        final tileset = map.tilesets[i];
        final image = tileset.tiles[j].image;
        if (image?.source != null) {
          imageSet.add((tileset.source, image!));
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
    final tilesetImageList = _onlyTileImages(map).toList();

    final mappedImageList = tilesetImageList.map((entry) {
      final tiledImage = entry.$2;
      var tileImageSource = tiledImage.source!;
      final tilesetSource = entry.$1;

      if (tilesetSource == null) {
        return (tileImageSource, tiledImage);
      }

      final tilesetParts = tilesetSource.split('/');
      final imageParts = tileImageSource.split('/');

      if (tilesetParts.length != imageParts.length) {
        tileImageSource = [
          ...tilesetParts.sublist(0, tilesetParts.length - 1),
          ...imageParts,
        ].join('/');
      }

      return (tileImageSource, tiledImage);
    });

    if (mappedImageList.isEmpty) {
      // so this map has no tiles... Ok.
      return TiledAtlas._(
        atlas: null,
        offsets: {},
        key: 'atlas{empty}',
      );
    }

    final imagesInstance = images ?? Flame.images;

    final imageList = mappedImageList.map((e) => e.$2).toList();

    final key = atlasKey(imageList);
    if (atlasMap.containsKey(key)) {
      return atlasMap[key]!.clone();
    }

    if (imageList.length == 1) {
      // The map contains one image, so its either an atlas already, or a
      // really boring map.
      final image = (await imagesInstance.load(key)).clone();

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
      ...mappedImageList.map(
        (entry) => imagesInstance.load(entry.$1),
      ),
    ]);

    final emptyPaint = Paint();
    for (final entry in mappedImageList) {
      final tiledImage = entry.$2;
      final tileImageSource = entry.$1;

      final image = await imagesInstance.load(tileImageSource);
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
