import 'package:flame_3d/src/parser/gltf/buffer_view.dart';
import 'package:flame_3d/src/parser/gltf/component_type.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// An object pointing to a buffer view containing the indices of deviating
/// accessor values.
/// The number of indices is equal to `accessor.sparse.count`. Indices **MUST**
/// strictly increase.
class SparseAccessorIndices({
  required super.root,

  /// The reference to the buffer view with sparse indices.
  /// The referenced buffer view **MUST NOT** have its `target` or `byteStride`
  /// properties defined.
  /// The buffer view and the optional `byteOffset` **MUST** be aligned to the
  /// `componentType` byte length."
  required final GltfRef<BufferView> bufferView,

  /// The offset relative to the start of the buffer view in bytes.
  required final int byteOffset,

  /// The indices data type.
  required final ComponentType componentType,
}) extends GltfNode {
  SparseAccessorIndices.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        bufferView: Parser.ref(root, map, 'bufferView')!,
        byteOffset: Parser.integer(map, 'byteOffset') ?? 0,
        componentType: ComponentType.parse(map, 'componentType')!,
      );
}
