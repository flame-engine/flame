library flame_texturepacker;

import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_texturepacker/src/texture_packer_parser.dart';
import 'package:flame_texturepacker/src/texture_packer_sprite.dart';

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
    String? package,
  }) async {
    final atlasData = await loadAtlas(
      path,
      fromStorage: fromStorage,
      images: images,
      assets: assets,
      assetsPrefix: assetsPrefix,
      package: package,
    );

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
  /// [assets] - Optional AssetsCache to use for loading assets
  /// [loadImages] - Whether to load images (default: true)
  ///
  /// Returns a [Future] that completes with the raw [TextureAtlasData].
  static Future<TextureAtlasData> loadAtlas(
    String path, {
    bool fromStorage = false,
    Images? images,
    AssetsCache? assets,
    String assetsPrefix = 'images',
    String? package,
    bool loadImages = true,
  }) async {
    try {
      final atlasData = await TexturePackerParser.parseAtlasMetadata(
        path,
        fromStorage: fromStorage,
        assets: assets,
        assetsPrefix: assetsPrefix,
        package: package,
      );

      if (loadImages) {
        await TexturePackerParser.loadAtlasDataImages(
          atlasData,
          path,
          fromStorage: fromStorage,
          images: images,
          package: package,
        );
      }
      return atlasData;
    } on Exception catch (e, stack) {
      final source = fromStorage ? 'storage' : 'assets';
      Error.throwWithStackTrace(
        Exception('Error loading $path from $source: $e'),
        stack,
      );
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
  /// If no exact match is found, it attempts to find sprites that look like
  /// indexed animation frames (e.g., "walk1", "walk_2") for that name.
  List<TexturePackerSprite> findSpritesByName(String name) {
    // 1. Try exact match (handles explicit index grouping)
    final exactMatches = sprites
        .where(
          (sprite) => sprite.region.name == name,
        )
        .toList();

    if (exactMatches.isNotEmpty) {
      return exactMatches
        ..sort((a, b) => a.region.index.compareTo(b.region.index));
    }

    // 2. Try fuzzy match for unstripped animation frames (e.g. walk1, walk_2)
    final fuzzyMatches = sprites.where((sprite) {
      final sName = sprite.region.name;
      if (!sName.startsWith(name)) {
        return false;
      }
      final tail = sName.substring(name.length);
      return RegExp(r'^_?\d+$').hasMatch(tail);
    }).toList();

    if (fuzzyMatches.isNotEmpty) {
      fuzzyMatches.sort((a, b) {
        // Use region.index if available (from explicit index: line)
        if (a.region.index != -1 && b.region.index != -1) {
          return a.region.index.compareTo(b.region.index);
        }
        // Otherwise extract from trailing digits of the name
        final aIdx = _parseTrailingIndex(a.region.name);
        final bIdx = _parseTrailingIndex(b.region.name);
        return aIdx.compareTo(bIdx);
      });
      return fuzzyMatches;
    }

    return [];
  }

  int _parseTrailingIndex(String name) {
    final match = RegExp(r'(\d+)$').firstMatch(name);
    return match != null ? int.parse(match.group(1)!) : -1;
  }

  /// Creates a [SpriteAnimation] from sprites with the given name.
  ///
  /// [name] - The name of the sprites to use for the animation
  /// [stepTime] - The duration to display each frame, in seconds
  /// [loop] - Whether the animation should loop
  SpriteAnimation getAnimation(
    String name, {
    double stepTime = 0.1,
    bool loop = true,
  }) {
    final animationSprites = findSpritesByName(name);
    if (animationSprites.isEmpty) {
      throw Exception('No sprites found with name "$name" in atlas');
    }
    return SpriteAnimation.spriteList(
      animationSprites,
      stepTime: stepTime,
      loop: loop,
    );
  }
}
