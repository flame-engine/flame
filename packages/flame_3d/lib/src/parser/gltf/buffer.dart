import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A buffer points to binary geometry, animation, or skins.
class Buffer({
  required super.root,

  /// The length of the buffer in bytes.
  required final int byteLength,

  /// The URI of the buffer.
  required final String? uri,
}) extends GltfNode {
  Buffer.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        byteLength: Parser.integer(map, 'byteLength')!,
        uri: Parser.string(map, 'uri'),
      );
}
