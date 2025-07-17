library flame_texturepacker;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame_texturepacker/src/model/page.dart';
import 'package:flame_texturepacker/src/model/region.dart';
import 'package:flame_texturepacker/src/texture_packer_sprite.dart';
import 'package:flutter/painting.dart';

/// A texture atlas that contains a collection of [TexturePackerSprite]s.
///
/// This class provides methods to load and query sprites from a texture atlas
/// created by TexturePacker or similar tools.
class TexturePackerAtlas {
  /// List of all sprites contained in this atlas.
  final List<TexturePackerSprite> sprites;

  /// Creates a new [TexturePackerAtlas] with the given [sprites].
  TexturePackerAtlas(this.sprites);

  /// Creates a [TexturePackerAtlas] from parsed atlas data.
  ///
  /// [atlasData] - The parsed atlas data containing pages and regions
  /// [whiteList] - Optional list of sprite names to include.
  ///               If empty, all sprites are included
  /// [useOriginalSize] - Use original sprite dimensions before packing or not.
  factory TexturePackerAtlas.fromAtlas(
    TextureAtlasData atlasData, {
    List<String> whiteList = const [],
    bool useOriginalSize = true,
  }) {
    return TexturePackerAtlas(
      atlasData.regions
          .where(
            (e) {
              return whiteList.isEmpty ||
                  whiteList.any((key) => e.name.contains(key));
            },
          )
          .map(
            (e) => TexturePackerSprite(
              e,
              useOriginalSize: useOriginalSize,
            ),
          )
          .toList(),
    );
  }

  /// Loads a texture atlas from a file path.
  ///
  /// [path] - The path to the atlas file
  /// [fromStorage] - Load from device storage (true) or assets (false)
  /// [useOriginalSize] - Use original sprite dimensions before packing or not.
  /// [images] - Optional Images cache to use for loading textures
  /// [assetsPrefix] - Prefix for asset paths (default: 'images')
  /// [assets] - Optional AssetsCache to use for loading assets
  /// [whiteList] - Optional list of sprite names to include.
  ///               If empty, all sprites are included
  ///
  /// Returns a [Future] that completes with the loaded [TexturePackerAtlas].
  static Future<TexturePackerAtlas> load(
    String path, {
    bool fromStorage = false,
    bool useOriginalSize = true,
    Images? images,
    String assetsPrefix = 'images',
    AssetsCache? assets,
    List<String> whiteList = const [],
  }) async {
    final TextureAtlasData atlasData;

    if (fromStorage) {
      atlasData = await _fromStorage(path, images: images);
    } else {
      atlasData = await _fromAssets(
        path,
        images: images,
        assets: assets,
        assetsPrefix: assetsPrefix,
      );
    }

    return TexturePackerAtlas.fromAtlas(
      atlasData,
      whiteList: whiteList,
      useOriginalSize: useOriginalSize,
    );
  }

  /// Loads atlas data without creating a [TexturePackerAtlas] instance.
  ///
  /// [path] - The path to the atlas file
  /// [fromStorage] - Load from device storage (true) or assets (false)
  /// [images] - Optional Images cache to use for loading textures
  /// [assetsPrefix] - Prefix for asset paths (default: 'images')
  ///
  /// Returns a [Future] that completes with the raw [TextureAtlasData].
  static Future<TextureAtlasData> loadAtlas(
    String path, {
    bool fromStorage = false,
    Images? images,
    String assetsPrefix = 'images',
  }) async {
    if (fromStorage) {
      return _fromStorage(path, images: images);
    } else {
      return _fromAssets(path, images: images, assetsPrefix: assetsPrefix);
    }
  }

  /// Finds a sprite by its name.
  ///
  /// [name] - The name of the sprite to find
  ///
  /// Returns the first [TexturePackerSprite] with the given name
  /// or null if not found.
  TexturePackerSprite? findSpriteByName(String name) {
    return sprites.firstWhereOrNull(
      (e) => e.region.name == name,
    );
  }

  /// Finds a sprite by its name and index.
  ///
  /// [name] - The name of the sprite to find
  /// [index] - The index of the sprite to find
  ///
  /// Returns the [TexturePackerSprite] with the given name and index
  /// or null if not found.
  TexturePackerSprite? findSpriteByNameIndex(String name, int index) {
    return sprites.firstWhereOrNull(
      (sprite) => sprite.region.name == name && sprite.region.index == index,
    );
  }

  /// Finds all sprites with the given name.
  ///
  /// [name] - The name of the sprites to find
  ///
  /// Returns a list of all [TexturePackerSprite]s with the given name.
  List<TexturePackerSprite> findSpritesByName(String name) {
    return sprites
        .where(
          (sprite) => sprite.region.name == name,
        )
        .toList();
  }
}

/// Loads texture atlas data from application assets.
///
/// [path] - The path to the atlas file
/// [assetsPrefix] - Prefix for asset paths
/// [images] - Optional Images cache to use for loading textures
/// [assets] - Optional AssetsCache to use for loading assets
///
/// Returns a [Future] that completes with the loaded [TextureAtlasData].
/// Throws an [Exception] if loading fails.
Future<TextureAtlasData> _fromAssets(
  String path, {
  required String assetsPrefix,
  Images? images,
  AssetsCache? assets,
}) async {
  try {
    return await _parse(
      path,
      fromStorage: false,
      images: images,
      assets: assets,
      assetsPrefix: assetsPrefix,
    );
  } on Exception catch (e, stack) {
    Error.throwWithStackTrace(
      Exception('Error loading $assetsPrefix$path from assets: $e'),
      stack,
    );
  }
}

/// Loads texture atlas data from device storage.
///
/// [path] - The path to the atlas file
/// [images] - Optional Images cache to use for loading textures
///
/// Returns a [Future] that completes with the loaded [TextureAtlasData].
/// Throws an [Exception] if loading fails.
Future<TextureAtlasData> _fromStorage(
  String path, {
  Images? images,
}) async {
  try {
    return await _parse(
      path,
      fromStorage: true,
      images: images,
    );
  } on Exception catch (e, stack) {
    Error.throwWithStackTrace(
      Exception('Error loading $path from storage: $e'),
      stack,
    );
  }
}

/// Parses a texture atlas file and returns the atlas data.
///
/// [path] - The path to the atlas file
/// [fromStorage] - Whether to load from device storage (true) or assets (false)
/// [images] - Optional Images cache to use for loading textures
/// [assets] - Optional AssetsCache to use for loading assets
/// [assetsPrefix] - Prefix for asset paths (required when fromStorage is false)
///
/// Returns a [Future] that completes with the parsed [TextureAtlasData].
Future<TextureAtlasData> _parse(
  String path, {
  required bool fromStorage,
  Images? images,
  AssetsCache? assets,
  String? assetsPrefix,
}) async {
  final pages = <Page>[];
  final regions = <Region>[];
  var hasIndexes = false;

  final fileContent = fromStorage
      ? await XFile(path).readAsString()
      : await (assets ?? Flame.assets).readFile('${assetsPrefix!}/$path');

  final lines = LineSplitter.split(fileContent).toList();
  final it = _LookaheadIterator(lines.iterator);

  images ??= Flame.images;

  while (_nextNonEmpty(it) != null) {
    final page = await _parsePage(it, path, fromStorage, images);
    pages.add(page);

    while (it.peek()?.isNotEmpty ?? false) {
      final region = _parseRegion(it, page);

      if (region.index != -1) {
        hasIndexes = true;
      }

      regions.add(region);
    }
  }

  if (hasIndexes) {
    regions.sort(
      (a, b) {
        final i1 = a.index == -1 ? double.maxFinite.toInt() : a.index;
        final i2 = b.index == -1 ? double.maxFinite.toInt() : b.index;
        return i1 - i2;
      },
    );
  }

  return (pages: pages, regions: regions);
}

/// Parses a page definition from the atlas file.
///
/// [it] - The iterator over atlas file lines
/// [path] - The path to the atlas file
/// [fromStorage] - Whether loading from device storage
/// [images] - Images cache to use for loading textures
///
/// Returns a [Future] that completes with the parsed [Page].
Future<Page> _parsePage(
  _LookaheadIterator it,
  String path,
  bool fromStorage,
  Images images,
) async {
  final page = Page();
  page.textureFile = it.next()!;

  final parentPath = (path.split('/')..removeLast()).join('/');
  final texturePath =
      parentPath.isEmpty ? page.textureFile : '$parentPath/${page.textureFile}';

  if (fromStorage) {
    final bytes = await XFile(texturePath).readAsBytes();
    final image = await decodeImageFromList(bytes);
    images.add(texturePath, image);
    page.texture = images.fromCache(texturePath);
  } else {
    page.texture = await images.load(texturePath);
  }

  _parsePageProperties(it, page);
  return page;
}

/// Parses page properties from the atlas file.
///
/// [it] - The iterator over atlas file lines
/// [page] - The page to populate with properties
void _parsePageProperties(_LookaheadIterator it, Page page) {
  while (true) {
    final line = it.peek();

    if (line == null || line.isEmpty) {
      break;
    }

    final (:count, :entry) = _readEntry(line);

    if (count == 0) {
      break;
    }

    switch (entry[0]) {
      case 'size':
        page.width = int.parse(entry[1]);
        page.height = int.parse(entry[2]);
      case 'filter':
        page.minFilter = entry[1];
        page.magFilter = entry[2];
      case 'format':
        page.format = entry[1];
      case 'repeat':
        page.repeat = entry[1];
    }

    it.next();
  }
}

/// Parses a region definition from the atlas file.
///
/// [it] - The iterator over atlas file lines
/// [page] - The page this region belongs to
///
/// Returns the parsed [Region].
Region _parseRegion(_LookaheadIterator it, Page page) {
  final name = it.next()!.trim();
  final values = <String, List<String>>{};

  while (true) {
    final line = it.peek();

    if (line == null || line.isEmpty) {
      break;
    }

    final (:count, :entry) = _readEntry(line);

    if (count == 0) {
      break;
    }

    values[entry[0]] = entry.sublist(1);
    it.next();
  }

  final xy = values['xy'];
  final size = values['size'];
  final bounds = values['bounds'];
  final offset = values['offset'];
  final orig = values['orig'];
  final offsets = values['offsets'];
  final rotate = values['rotate'];
  final index = values['index'];

  final offsetOrNull = offsets ?? offset;

  final offsetX = offsetOrNull != null ? double.parse(offsetOrNull[0]) : 0.0;

  final offsetY = offsetOrNull != null ? double.parse(offsetOrNull[1]) : 0.0;

  final origWidth = offsets != null
      ? double.parse(offsets[2])
      : (orig != null ? double.parse(orig[0]) : 0.0);

  final originalWidth = origWidth == 0.0 ? null : origWidth;

  final origHeight = offsets != null
      ? double.parse(offsets[3])
      : (orig != null ? double.parse(orig[1]) : 0.0);

  final originalHeight = origHeight == 0.0 ? null : origHeight;

  return Region(
    page: page,
    name: name,
    left: bounds != null
        ? double.parse(bounds[0])
        : (xy != null ? double.parse(xy[0]) : 0.0),
    top: bounds != null
        ? double.parse(bounds[1])
        : (xy != null ? double.parse(xy[1]) : 0.0),
    width: bounds != null
        ? double.parse(bounds[2])
        : (size != null ? double.parse(size[0]) : 0.0),
    height: bounds != null
        ? double.parse(bounds[3])
        : (size != null ? double.parse(size[1]) : 0.0),
    offsetX: offsetX,
    offsetY: offsetY,
    originalWidth: originalWidth,
    originalHeight: originalHeight,
    degrees: _parseDegrees(rotate?.first),
    rotate: _parseDegrees(rotate?.first) == 90,
    index: index != null ? int.parse(index[0]) : -1,
  );
}

/// Finds the next non-empty line in the iterator.
///
/// [it] - The iterator over atlas file lines
///
/// Returns the next non-empty line, or null if none found.
String? _nextNonEmpty(_LookaheadIterator it) {
  while (!it.isDone) {
    final line = it.peek();

    if (line != null && line.isNotEmpty) {
      return line;
    }

    it.next();
  }

  return null;
}

/// Parses rotation degrees from a string value.
///
/// [value] - The string value to parse ('true', 'false', or numeric string)
///
/// Returns the rotation in degrees (0, 90, or parsed integer value).
int _parseDegrees(String? value) {
  if (value == null) {
    return 0;
  }

  if (value == 'true') {
    return 90;
  }

  if (value == 'false') {
    return 0;
  }

  return int.parse(value);
}

/// Parses a single entry line from the atlas file.
///
/// [line] - The line to parse
///
/// Returns a record containing the count of parsed values and the entry list.
({int count, List<String> entry}) _readEntry(String line) {
  final trimmedLine = line.trim();

  if (trimmedLine.isEmpty) {
    return (count: 0, entry: []);
  }

  final colonIndex = trimmedLine.indexOf(':');

  if (colonIndex == -1) {
    return (count: 0, entry: []);
  }

  final entry = <String>[];
  entry.add(trimmedLine.substring(0, colonIndex).trim());

  for (var i = 1, lastMatch = colonIndex + 1;; i++) {
    final commaIndex = trimmedLine.indexOf(',', lastMatch);

    if (commaIndex == -1) {
      entry.add(trimmedLine.substring(lastMatch).trim());
      return (count: i, entry: entry);
    }

    entry.add(trimmedLine.substring(lastMatch, commaIndex).trim());
    lastMatch = commaIndex + 1;

    if (i == 4) {
      return (count: 4, entry: entry);
    }
  }
}

/// A lookahead iterator that allows peeking at the next value without consuming
///
/// This is useful for parsing where you need to check the next line
/// before deciding whether to consume it.
class _LookaheadIterator {
  /// The underlying iterator.
  final Iterator<String> _it;

  /// The current lookahead value.
  String? _lookahead;

  /// Creates a new lookahead iterator wrapping the given iterator.
  ///
  /// [_it] - The iterator to wrap
  _LookaheadIterator(this._it) {
    _advance();
  }

  /// Returns the next value without consuming it.
  ///
  /// Returns null if there are no more values.
  String? peek() => _lookahead;

  /// Consumes and returns the next value.
  ///
  /// Returns null if there are no more values.
  String? next() {
    final current = _lookahead;
    _advance();
    return current;
  }

  /// Whether the iterator has reached the end.
  bool get isDone => _lookahead == null;

  /// Advances the iterator to the next value.
  void _advance() {
    if (_it.moveNext()) {
      _lookahead = _it.current;
    } else {
      _lookahead = null;
    }
  }
}

/// Type definition for texture atlas data containing pages and regions.
///
/// This is a record type with two fields:
/// - [List<Page> pages]: List of texture pages
/// - [List<Region> regions]: List of sprite regions
typedef TextureAtlasData = ({List<Page> pages, List<Region> regions});
