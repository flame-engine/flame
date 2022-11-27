import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/src/rectangle_bin_packer.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

/// One image atlas for all Tiled image sets in a map.
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
  TiledAtlas._(this.atlas, this.offsets, this.key)
      : batch = atlas == null ? null : SpriteBatch(atlas, imageKey: key);

  /// Returns whether or not this atlas contains [source].
  bool contains(String? source) => offsets.containsKey(source);

  /// Create a new atlas from this object with the intent of getting a new
  /// [SpriteBatch].
  TiledAtlas clone() => TiledAtlas._(atlas?.clone(), offsets, key);

  /// Maps of tilesets compiled to [TiledAtlas].
  @visibleForTesting
  static final atlasMap = <String, TiledAtlas>{};

  @visibleForTesting
  static String atlasKey(Iterable<TiledImage> images) {
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
  static Future<TiledAtlas> fromTiledMap(TiledMap map) async {
    final imageList = _onlyTileImages(map).toList();

    if (imageList.isEmpty) {
      // so this map has no tiles... Ok.
      return TiledAtlas._(null, {}, 'atlas{empty}');
    }

    final key = atlasKey(imageList);
    if (atlasMap.containsKey(key)) {
      return atlasMap[key]!.clone();
    }

    if (imageList.length == 1) {
      // The map contains one image, so its either an atlas already, or a
      // really boring map.
      final tiledImage = imageList.first;
      final image =
          (await Flame.images.load(tiledImage.source!, key: key)).clone();

      return atlasMap[key] ??=
          TiledAtlas._(image, {tiledImage.source!: Offset.zero}, key);
    }

    final bin = RectangleBinPacker();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final _emptyPaint = Paint();

    final offsetMap = <String, Offset>{};

    var pictureRect = Rect.zero;

    imageList.sort((b, a) {
      final height = a.height! - b.height!;
      return height != 0 ? height : a.width! - b.width!;
    });

    // parallelize the download of images.
    await Future.wait([
      ...imageList.map((tiledImage) => Flame.images.load(tiledImage.source!))
    ]);

    for (final tiledImage in imageList) {
      final image = await Flame.images.load(tiledImage.source!);
      final rect = bin.pack(image.width.toDouble(), image.height.toDouble());

      pictureRect = pictureRect.expandToInclude(rect);

      final offset =
          offsetMap[tiledImage.source!] = Offset(rect.left, rect.top);

      canvas.drawImage(image, offset, _emptyPaint);
    }
    final picture = recorder.endRecording();
    final image = await picture.toImageSafe(
      pictureRect.width.toInt(),
      pictureRect.height.toInt(),
    );
    Flame.images.add(key, image);
    return atlasMap[key] = TiledAtlas._(image, offsetMap, key);
  }
}
