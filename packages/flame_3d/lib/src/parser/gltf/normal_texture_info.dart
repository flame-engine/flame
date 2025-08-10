import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/texture_info.dart';

/// Material Normal Texture Info.
class NormalTextureInfo extends TextureInfo {
  /// The scalar parameter applied to each normal vector of the texture.
  ///
  /// This value scales the normal vector in X and Y directions using the
  /// formula:
  ///
  /// ```
  ///   scaledNormal =  normalize((<sampled normal texture value> * 2.0 - 1.0)
  ///                       * vec3(<normal scale>, <normal scale>, 1.0))
  /// ```
  final double scale;

  NormalTextureInfo({
    required super.root,
    required super.index,
    required super.texCoord,
    required this.scale,
  });

  NormalTextureInfo.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        index: Parser.ref(root, map, 'index')!,
        texCoord: Parser.integer(map, 'texCoord'),
        scale: Parser.float(map, 'scale') ?? 1.0,
      );
}
