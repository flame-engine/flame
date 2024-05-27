library flame_texturepacker;

import 'package:flame/cache.dart';
import 'package:flame/game.dart';
import 'package:flame_texturepacker/src/texture_packer_atlas.dart';

export 'package:flame_texturepacker/src/texture_packer_atlas.dart';
export 'package:flame_texturepacker/src/texture_packer_sprite.dart';

extension TexturepackerLoader on Game {
  /// Loads the specified pack file.
  /// Uses the parent directory of the pack file to find the page images.
  @Deprecated('Use [atlasFromAssets] or [atlasFromStorage] instead')
  Future<TexturePackerAtlas> fromAtlas(
    String assetsPath, {
    bool fromStorage = false,
    Images? images,
  }) async =>
      TexturePackerAtlas.load(
        assetsPath,
        fromStorage: fromStorage,
        images: images,
      );

  /// Loads the specified pack file from assets
  /// Uses the parent directory of the pack file to find the page images.
  Future<TexturePackerAtlas> atlasFromAssets(
    String assetsPath, {
    Images? images,
  }) async =>
      TexturePackerAtlas.load(assetsPath, images: images);

  /// Loads the specified pack file from storage
  /// Uses the parent directory of the pack file to find the page images.
  Future<TexturePackerAtlas> atlasFromStorage(
    String storagePath, {
    Images? images,
  }) async =>
      TexturePackerAtlas.load(storagePath, fromStorage: true, images: images);
}
