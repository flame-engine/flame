import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A buffer points to binary geometry, animation, or skins.
class Buffer extends GltfNode {
  /// The length of the buffer in bytes.
  final int byteLength;

  /// The URI of the buffer.
  final String? uri;

  Buffer({
    required super.root,
    required this.byteLength,
    required this.uri,
  });

  Buffer.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        byteLength: Parser.integer(map, 'byteLength')!,
        uri: Parser.string(map, 'uri'),
      );
}
