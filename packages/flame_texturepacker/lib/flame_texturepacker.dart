library flame_texturepacker;

import 'package:flame/game.dart';
import 'package:flame_texturepacker/src/texture_packer_atlas.dart';

export 'package:flame_texturepacker/src/texture_packer_atlas.dart';
export 'package:flame_texturepacker/src/texture_packer_sprite.dart';

extension TexturepackerLoader on Game {
  /// Loads the specified pack file.
  /// Uses the parent directory of the pack file to find the page images.
  Future<TexturePackerAtlas> fromAtlas(
    String assetsPath, {
    bool fromStorage = false,
  }) async =>
      TexturePackerAtlas.load(assetsPath, fromStorage: fromStorage);
}
