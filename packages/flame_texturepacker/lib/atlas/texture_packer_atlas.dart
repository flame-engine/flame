library flame_texturepacker;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame_texturepacker/atlas/model/page.dart';
import 'package:flame_texturepacker/atlas/model/region.dart';
import 'package:flame_texturepacker/atlas/model/texture_packer_sprite.dart';

final _images = Images(prefix: 'assets/');

class TexturePackerAtlas {
  final sprites = <TexturePackerSprite>[];

  /// Returns the first region found with the specified name. This method uses
  /// string comparison to find the region, so the result should be cached
  /// rather than calling this method multiple times.
  TexturePackerSprite? findSpriteByName(String name) =>
      sprites.firstWhereOrNull((e) => e.name == name);

  /// Returns the first region found with the specified name and index.
  /// This method uses string comparison to find the region, so the result
  /// should be cached rather than calling this method multiple times.
  TexturePackerSprite? findSpriteByNameIndex(String name, int index) {
    for (final sprite in sprites) {
      if (sprite.name == name && sprite.index == index) {
        return sprite;
      }
    }
    return null;
  }

  /// Returns all regions with the specified name, ordered by smallest to
  /// largest index. This method uses string comparison to find the regions, so
  /// the result should be cached rather than calling this method multiple
  /// times.
  List<TexturePackerSprite> findSpritesByName(String name) {
    final matched = <TexturePackerSprite>[];
    for (final sprite in sprites) {
      if (sprite.name == name) {
        matched.add(sprite);
      }
    }
    return matched;
  }

  Future<TexturePackerAtlas> load(String path) async {
    final atlasData = await _TextureAtlasData()._load(path);

    for (final region in atlasData.regions) {
      sprites.add(TexturePackerSprite(region));
    }
    return this;
  }
}

class _TextureAtlasData {
  final pages = <Page>[];
  final regions = <Region>[];

  Future<_TextureAtlasData> _load(String path) async {
    final fileAsString = await Flame.assets.readFile(path);

    final iterator = LineSplitter.split(fileAsString).iterator;
    var line = iterator.moveNextAndGet();
    var hasIndexes = false;
    while (true) {
      if (line == null) {
        break;
      }
      if (line.isEmpty) {
        line = iterator.moveNextAndGet();
      }

      Page? page;
      while (true) {
        if (line == null) {
          break;
        }
        if (line.isEmpty) {
          page = null;
          line = iterator.moveNextAndGet();
        } else if (page == null) {
          page = Page();
          page.textureFile = line;
          final parentPath = (path.split('/')..removeLast()).join('/');
          final texturePath = '$parentPath/$line';
          page.texture = await _images.load(texturePath);
          while (true) {
            line = iterator.moveNextAndGet();
            if (line == null) {
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
          }
          pages.add(page);
        } else {
          final region = Region();
          region.page = page;
          region.name = line.trim();
          while (true) {
            line = iterator.moveNextAndGet();
            if (line == null) {
              break;
            }
            final (:count, :entry) = _readEntry(line);
            if (count == 0) {
              break;
            }
            switch (entry[0]) {
              case 'xy':
                region.left = double.parse(entry[1]);
                region.top = double.parse(entry[2]);
              case 'size':
                region.width = double.parse(entry[1]);
                region.height = double.parse(entry[2]);
              case 'bounds':
                region.left = double.parse(entry[1]);
                region.top = double.parse(entry[2]);
                region.width = double.parse(entry[3]);
                region.height = double.parse(entry[4]);
              case 'offset':
                region.offsetX = double.parse(entry[1]);
                region.offsetY = double.parse(entry[2]);
              case 'orig':
                region.originalWidth = double.parse(entry[1]);
                region.originalHeight = double.parse(entry[2]);
              case 'offsets':
                region.offsetX = double.parse(entry[1]);
                region.offsetY = double.parse(entry[2]);
                region.originalWidth = double.parse(entry[3]);
                region.originalHeight = double.parse(entry[4]);
              case 'rotate':
                final value = entry[1];
                if (value == 'true') {
                  region.degrees = 90;
                } else if (value == 'false') {
                  region.degrees = 0;
                } else {
                  region.degrees = int.parse(value);
                }
                region.rotate = region.degrees == 90;
              case 'index':
                region.index = int.parse(entry[1]);
                if (region.index != -1) {
                  hasIndexes = true;
                }
            }
          }
          if (region.originalWidth == 0 && region.originalHeight == 0) {
            region.originalWidth = region.width;
            region.originalHeight = region.height;
          }
          regions.add(region);
        }
      }
    }
    if (hasIndexes) {
      regions.sort((region1, region2) {
        var i1 = region1.index;
        if (i1 == -1) {
          i1 = double.maxFinite.toInt();
        }
        var i2 = region2.index;
        if (i2 == -1) {
          i2 = double.maxFinite.toInt();
        }
        return i1 - i2;
      });
    }
    return this;
  }

  ({int count, List<String> entry}) _readEntry(String inputLine) {
    final line = inputLine.trim();
    if (line.isEmpty) {
      return (count: 0, entry: []);
    }
    final colonIndex = line.indexOf(':');
    if (colonIndex == -1) {
      return (count: 0, entry: []);
    }
    final entry = <String>[];
    entry.add(line.substring(0, colonIndex).trim());
    for (var i = 1, lastMatch = colonIndex + 1;; i++) {
      final commaIndex = line.indexOf(',', lastMatch);
      if (commaIndex == -1) {
        entry.add(line.substring(lastMatch).trim());
        return (count: i, entry: entry);
      }
      entry.add(line.substring(lastMatch, commaIndex).trim());
      lastMatch = commaIndex + 1;
      if (i == 4) {
        return (count: 4, entry: entry);
      }
    }
  }
}

extension _IteratorExtension on Iterator<String> {
  String? moveNextAndGet() {
    if (moveNext()) {
      return current;
    }
    return null;
  }
}
