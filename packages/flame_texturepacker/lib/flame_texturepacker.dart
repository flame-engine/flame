library flame_texturepacker;

import 'package:flame/game.dart';
import 'package:flame_texturepacker/atlas/texture_packer_atlas.dart';

export 'package:flame_texturepacker/atlas/model/texture_packer_sprite.dart';

extension TexturepackerLoader on Game {
  /// Loads the specified pack file, using the parent directory of the pack file
  /// to find the page images.
  Future<TexturePackerAtlas> fromAtlas(String assetsPath) async =>
      TexturePackerAtlas.load(assetsPath);
}
