import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/texture_info.dart';

/// The occlusion texture.
class OcclusionTextureInfo({
  required super.root,
  required super.index,
  required super.texCoord,

  /// A scalar parameter controlling the amount of occlusion applied.
  ///
  /// A value of `0.0` means no occlusion. A value of `1.0` means full
  /// occlusion.
  ///
  /// This value affects the final occlusion value as:
  /// ```'
  ///   1.0 + strength * (<sampled occlusion texture value> - 1.0)
  /// ```
  required final double strength,
}) extends TextureInfo {
  OcclusionTextureInfo.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        index: Parser.ref(root, map, 'index')!,
        texCoord: Parser.integer(map, 'texCoord'),
        strength: Parser.float(map, 'strength') ?? 1.0,
      );
}
