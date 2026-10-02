import 'package:flame_3d/src/parser/gltf/buffer_view.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// An object pointing to a buffer view containing the deviating accessor
/// values.
/// The number of elements is equal to `accessor.sparse.count` times number of
/// components.
/// The elements have the same component type as the base accessor.
/// The elements are tightly packed. Data **MUST** be aligned following the
/// same rules as the base accessor.
class SparseAccessorValues({
  required super.root,

  /// The index of the bufferView with sparse values.
  /// The referenced buffer view **MUST NOT** have its `target` or `byteStride`
  /// properties defined.
  required final GltfRef<BufferView> bufferView,

  /// The offset relative to the start of the bufferView in bytes.
  required final int byteOffset,
}) extends GltfNode {
  SparseAccessorValues.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        bufferView: Parser.ref(root, map, 'bufferView')!,
        byteOffset: Parser.integer(map, 'byteOffset') ?? 0,
      );
}
