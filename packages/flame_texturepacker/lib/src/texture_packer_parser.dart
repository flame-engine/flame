import 'dart:collection';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame_texturepacker/src/model/page.dart';
import 'package:flame_texturepacker/src/model/region.dart';
import 'package:flutter/painting.dart';

/// Type definition for texture atlas data containing pages and regions.
typedef TextureAtlasData = ({List<Page> pages, List<Region> regions});

/// Internal parser for TexturePacker atlas files.
abstract class TexturePackerParser {
  /// Parses structural data of a texture atlas file.
  static Future<TextureAtlasData> parseAtlasMetadata(
    String path, {
    required bool fromStorage,
    AssetsCache? assets,
    String? assetsPrefix,
    String? package,
  }) async {
    final pages = <Page>[];
    final regions = <Region>[];

    final String fileContent;
    if (fromStorage) {
      fileContent = await XFile(path).readAsString();
    } else {
      final assetsCache = assets ?? Flame.assets;
      final prefix = (assetsPrefix ?? '').trim();
      final cleanPath = path.trim().replaceFirst(RegExp('^/'), '');

      var fullPath = cleanPath;
      if (prefix.isNotEmpty &&
          !cleanPath.contains('packages/') &&
          !cleanPath.startsWith('assets/')) {
        final effectivePrefix = prefix.endsWith('/') ? prefix : '$prefix/';
        if (!cleanPath.startsWith(effectivePrefix)) {
          fullPath = '$effectivePrefix$cleanPath';
        }
      }

      final resolved = resolvePath(fullPath, package);
      final finalPath = resolved.path.startsWith(assetsCache.prefix)
          ? resolved.path.substring(assetsCache.prefix.length)
          : resolved.path;

      fileContent = await assetsCache.readFile(
        finalPath,
        package: resolved.package,
      );
    }

    final lines = LineSplitter.split(
      fileContent,
    ).where((line) => line.trim().isNotEmpty);

    final lineQueue = ListQueue<String>.from(lines);

    while (lineQueue.isNotEmpty) {
      final page = _parsePageMetadata(lineQueue);
      pages.add(page);

      while (lineQueue.isNotEmpty) {
        final line = lineQueue.first.trim();

        if (isTextureFile(line)) {
          if (lineQueue.length > 1) {
            final nextLine = lineQueue.elementAt(1).trim();
            final isRegionProperty =
                nextLine.startsWith('bounds:') ||
                nextLine.startsWith('rotate:') ||
                nextLine.startsWith('xy:') ||
                nextLine.startsWith('offsets:') ||
                nextLine.startsWith('orig:') ||
                nextLine.startsWith('offset:') ||
                nextLine.startsWith('index:');

            if (isRegionProperty) {
              final region = _parseRegion(lineQueue, page);
              regions.add(region);
              continue;
            }
          }
          break;
        }

        final region = _parseRegion(lineQueue, page);
        regions.add(region);
      }
    }

    final hasIndexes = regions.any((r) => r.index != -1);

    if (hasIndexes) {
      regions.sort((a, b) {
        final i1 = a.index == -1 ? 0x7FFFFFFF : a.index;
        final i2 = b.index == -1 ? 0x7FFFFFFF : b.index;
        return i1 - i2;
      });
    }

    return (pages: pages, regions: regions);
  }

  /// Loads images for all pages in the given atlas data.
  static Future<void> loadAtlasDataImages(
    TextureAtlasData atlasData,
    String path, {
    required bool fromStorage,
    Images? images,
    String? package,
    String? assetsPrefix,
    AssetsCache? assets,
  }) async {
    final img = images ?? Flame.images;
    for (final page in atlasData.pages) {
      final parentPath = (path.split('/')..removeLast()).join('/');
      var texturePath = parentPath.isEmpty
          ? page.textureFile
          : '$parentPath/${page.textureFile}';

      if (fromStorage) {
        final bytes = await XFile(texturePath).readAsBytes();
        final image = await decodeImageFromList(bytes);
        img.add(texturePath, image);
        page.texture = img.fromCache(texturePath);
      } else {
        final prefix = (assetsPrefix ?? '').trim();
        if (prefix.isNotEmpty &&
            !texturePath.contains('packages/') &&
            !texturePath.startsWith('assets/')) {
          final effectivePrefix = prefix.endsWith('/') ? prefix : '$prefix/';
          if (!texturePath.startsWith(effectivePrefix)) {
            texturePath = '$effectivePrefix$texturePath';
          }
        }

        final resolved = resolvePath(texturePath, package);
        final assetsCachePrefix = (assets ?? Flame.assets).prefix;

        String toRelative(String p) => p.startsWith(assetsCachePrefix)
            ? p.substring(assetsCachePrefix.length)
            : p;

        final relativePath = toRelative(resolved.path);
        final relativePrefix = toRelative(img.prefix);

        final finalTexturePath =
            (relativePrefix.isNotEmpty &&
                relativePath.startsWith(relativePrefix))
            ? relativePath.substring(relativePrefix.length)
            : relativePath;

        page.texture = await img.load(
          finalTexturePath,
          package: resolved.package,
        );
      }
    }
  }

  static Page _parsePageMetadata(ListQueue<String> lineQueue) {
    final page = Page();
    page.textureFile = lineQueue.removeFirst();

    while (lineQueue.isNotEmpty && lineQueue.first.contains(':')) {
      final line = lineQueue.removeFirst();
      final parts = line.split(':');
      final key = parts[0].trim();
      final value = parts[1].trim();

      if (key == 'size') {
        final sizeParts = value.split(',');
        page.width = int.parse(sizeParts[0]);
        page.height = int.parse(sizeParts[1]);
      } else if (key == 'format') {
        page.format = value;
      } else if (key == 'filter') {
        final filterParts = value.split(',');
        page.minFilter = filterParts[0];
        page.magFilter = filterParts[1];
      } else if (key == 'repeat') {
        page.repeat = value;
      }
    }

    return page;
  }

  static Region _parseRegion(ListQueue<String> lineQueue, Page page) {
    final originalName = lineQueue.removeFirst().trim();
    var name = originalName;
    var extractedIndex = -1;

    final extensionMatch = RegExp(
      r'\.(png|jpg|jpeg|bmp|tga|webp)$',
      caseSensitive: false,
    ).firstMatch(name);
    if (extensionMatch != null) {
      name = name.substring(0, extensionMatch.start);
    }

    final nameBeforeIndex = name;

    final indexMatch = RegExp(r'(_?)(\d+)$').firstMatch(name);
    if (indexMatch != null) {
      try {
        extractedIndex = int.parse(indexMatch.group(2)!);
        name = name.substring(0, indexMatch.start);
      } on FormatException catch (e, stack) {
        Error.throwWithStackTrace(
          FormatException(
            'Failed to parse index from sprite name "$name". '
            'Ensure the numeric suffix fits within an integer range.',
          ),
          stack,
        );
      }
    }

    final values = <String, List<String>>{};

    while (lineQueue.isNotEmpty) {
      final line = lineQueue.first.trim();

      if (isTextureFile(line)) {
        break;
      }

      final (:count, :entry) = _readEntry(line);

      if (count == 0) {
        break;
      }

      values[entry[0]] = entry.sublist(1);
      lineQueue.removeFirst();
    }

    final indexValue = values['index'];
    if (indexValue != null) {
      extractedIndex = int.parse(indexValue[0]);
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

    final originalWidth = offsets != null
        ? double.parse(offsets[2])
        : (orig != null ? double.parse(orig[0]) : 0.0);

    final finalOriginalWidth = originalWidth == 0.0 ? null : originalWidth;

    final originalHeight = offsets != null
        ? double.parse(offsets[3])
        : (orig != null ? double.parse(orig[1]) : 0.0);

    final finalOriginalHeight = originalHeight == 0.0 ? null : originalHeight;

    final finalIndex = index != null ? int.parse(index[0]) : extractedIndex;
    final finalName = finalIndex == -1 ? nameBeforeIndex : name;

    return Region(
      page: page,
      name: finalName,
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
      originalWidth: finalOriginalWidth,
      originalHeight: finalOriginalHeight,
      degrees: _parseDegrees(rotate?.first),
      rotate: _parseDegrees(rotate?.first) == 90,
      index: finalIndex,
    );
  }

  static bool isTextureFile(String line) {
    const imageExtensions = ['.png', '.jpg', '.jpeg', '.bmp', '.tga', '.webp'];
    final trimmed = line.trim().toLowerCase();
    return imageExtensions.any(trimmed.endsWith);
  }

  static ({String path, String? package}) resolvePath(
    String path,
    String? package,
  ) {
    const pkg = 'packages/';
    final index = path.indexOf(pkg);
    if (index != -1) {
      final subPath = path.substring(index + pkg.length);
      final segments = subPath.split('/');
      if (segments.length > 1) {
        return (
          path: segments.sublist(1).join('/'),
          package: package ?? segments[0],
        );
      }
    }
    return (path: path, package: package);
  }

  static int _parseDegrees(String? value) {
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

  static ({int count, List<String> entry}) _readEntry(String line) {
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
    for (var i = 1, lastMatch = colonIndex + 1; ; i++) {
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
}
