import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/image.dart';
import 'package:flame_3d/src/parser/gltf/sampler.dart';
import 'package:flame_3d/src/parser/gltf/texture_format.dart';
import 'package:flame_3d/src/parser/gltf/texture_target.dart';
import 'package:flame_3d/src/parser/gltf/texture_type.dart';

class Texture({
  required super.root,
  required final TextureFormat format,
  required final TextureFormat internalFormat,
  required final GltfRef<Sampler>? sampler,
  required final GltfRef<Image> source,
  required final TextureTarget target,
  required final TextureType type,
}) extends GltfNode {
  Texture.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        format: TextureFormat.parse(map, 'format') ?? TextureFormat.rgba,
        internalFormat:
            TextureFormat.parse(map, 'internalFormat') ?? TextureFormat.rgba,
        sampler: Parser.ref<Sampler>(root, map, 'sampler'),
        source: Parser.ref<Image>(root, map, 'source')!,
        target: TextureTarget.parse(map, 'target') ?? TextureTarget.texture2d,
        type: TextureType.parse(map, 'type') ?? TextureType.unsignedByte,
      );

  flame_3d.Texture toFlameTexture() {
    final imgTex = source.get().toFlameTexture();
    final flameSampler = sampler?.get().toFlameSampler();
    if (flameSampler == null) {
      return imgTex;
    }
    return flame_3d.ImageTexture(
      imgTex.sourceData,
      width: imgTex.width,
      height: imgTex.height,
      sampler: flameSampler,
      mipmaps: imgTex.mipmaps,
      gpuTexture: imgTex.gpuTexture,
    );
  }
}
