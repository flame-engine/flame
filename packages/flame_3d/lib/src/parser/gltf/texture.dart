import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/image.dart';
import 'package:flame_3d/src/parser/gltf/sampler.dart';
import 'package:flame_3d/src/parser/gltf/texture_format.dart';
import 'package:flame_3d/src/parser/gltf/texture_target.dart';
import 'package:flame_3d/src/parser/gltf/texture_type.dart';

class Texture extends GltfNode {
  /// The texture's format. Defaults to `6408` (RGBA).
  final TextureFormat format;

  /// The texture's internal format. Defaults to `6408` (RGBA).
  final TextureFormat internalFormat;

  /// The reference to the sampler used by this texture.
  final GltfRef<Sampler>? sampler;

  /// The reference to the image used by this texture.
  final GltfRef<Image> source;

  /// The target that the WebGL texture should be bound to.
  ///
  /// Valid values correspond to WebGL enums: `3553` (TEXTURE_2D).
  final TextureTarget target;

  /// Texel datatype. Defaults to `5121` (UNSIGNED_BYTE).
  final TextureType type;

  Texture({
    required super.root,
    required this.format,
    required this.internalFormat,
    required this.sampler,
    required this.source,
    required this.target,
    required this.type,
  });

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
    // TODO(luan): consider other parameters, such as sampler, type, etc
    return source.get().toFlameTexture();
  }
}
