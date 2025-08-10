import 'package:flame_3d/src/parser/gltf/buffer_view.dart';
import 'package:flame_3d/src/parser/gltf/component_type.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// An object pointing to a buffer view containing the indices of deviating
/// accessor values.
/// The number of indices is equal to `accessor.sparse.count`. Indices **MUST**
/// strictly increase.
class SparseAccessorIndices extends GltfNode {
  /// The reference to the buffer view with sparse indices.
  /// The referenced buffer view **MUST NOT** have its `target` or `byteStride`
  /// properties defined.
  /// The buffer view and the optional `byteOffset` **MUST** be aligned to the
  /// `componentType` byte length."
  final GltfRef<BufferView> bufferView;

  /// The offset relative to the start of the buffer view in bytes.
  final int byteOffset;

  /// The indices data type.
  final ComponentType componentType;

  SparseAccessorIndices({
    required super.root,
    required this.bufferView,
    required this.byteOffset,
    required this.componentType,
  });

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
