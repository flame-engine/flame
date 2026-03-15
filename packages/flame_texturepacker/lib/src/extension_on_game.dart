import 'package:flame/cache.dart';
import 'package:flame/game.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';

extension TexturepackerLoader on Game {
  /// Loads the specified pack file from assets
  /// Uses the parent directory of the pack file to find the page images.
  Future<TexturePackerAtlas> atlasFromAssets(
    String assetsPath, {
    Images? images,
    AssetsCache? assets,
    bool useOriginalSize = true,
    List<String> whiteList = const [],
    String assetsPrefix = 'images',
    String? package,
  }) =>
      TexturePackerAtlas.load(
        assetsPath,
        images: images ?? this.images,
        assets: assets ?? this.assets,
        useOriginalSize: useOriginalSize,
        whiteList: whiteList,
        assetsPrefix: assetsPrefix,
        package: package,
      );

  /// Loads the specified pack file from storage
  /// Uses the parent directory of the pack file to find the page images.
  Future<TexturePackerAtlas> atlasFromStorage(
    String storagePath, {
    Images? images,
    bool useOriginalSize = true,
    List<String> whiteList = const [],
  }) =>
      TexturePackerAtlas.load(
        storagePath,
        fromStorage: true,
        images: images ?? this.images,
        useOriginalSize: useOriginalSize,
        whiteList: whiteList,
      );
}
