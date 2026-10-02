import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/sparse_accessor_indices.dart';
import 'package:flame_3d/src/parser/gltf/sparse_accessor_values.dart';

/// Sparse storage of accessor values that deviate from their initialization
/// value.
class SparseAccessor({
  required super.root,

  /// Number of deviating accessor values stored in the sparse array.
  required final int count,

  /// An object pointing to a buffer view containing the indices of deviating
  /// accessor values.
  /// The number of indices is equal to `count`.
  /// Indices **MUST** strictly increase.
  required final SparseAccessorIndices indices,

  /// An object pointing to a buffer view containing the deviating
  /// accessor values.
  required final SparseAccessorValues values,
}) extends GltfNode {
  SparseAccessor.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        count: Parser.integer(map, 'count') ?? 0,
        indices: Parser.object(
          root,
          map,
          'indices',
          SparseAccessorIndices.parse,
        )!,
        values: Parser.object(
          root,
          map,
          'values',
          SparseAccessorValues.parse,
        )!,
      );
}
