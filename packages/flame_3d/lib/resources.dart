import 'package:flame/cache.dart';
import 'package:flame_3d/resources.dart';

export 'src/resources/material.dart';
export 'src/resources/mesh.dart';
export 'src/resources/resource.dart';
export 'src/resources/shader.dart';
export 'src/resources/texture.dart';

extension TextureCache on Images {
  Future<Texture> loadTexture(String path) =>
      load('crate.jpg').then(ImageTexture.create);
}
