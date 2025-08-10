import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/texture.dart';

// cSpell:ignore TEXCOORD
// (used in GLTF as the key for texture coordinate attributes)

/// Reference to a texture.
class TextureInfo extends GltfNode {
  /// The reference to the texture.
  final GltfRef<Texture> index;

  /// This integer value is used to construct a string in the format
  /// `TEXCOORD_<set index>`, which is a reference to a key in
  /// `mesh.primitives.attributes`
  /// (e.g. a value of `0` corresponds to `TEXCOORD_0`).
  ///
  /// A mesh primitive **MUST** have the corresponding texture coordinate
  /// attributes for the material to be applicable to it.
  final int? texCoord;

  TextureInfo({
    required super.root,
    required this.index,
    this.texCoord,
  });

  TextureInfo.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        index: Parser.ref(root, map, 'index')!,
        texCoord: Parser.integer(map, 'texCoord'),
      );

  flame_3d.Texture toFlameTexture() {
    return index.get().toFlameTexture();
  }
}
