import 'dart:typed_data';

import 'package:flame_3d/src/parser/gltf/buffer.dart';
import 'package:flame_3d/src/parser/gltf/buffer_view_target.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node_with_data.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A view into a buffer generally representing a subset of the buffer.
class BufferView extends GltfNode with GltfNodeWithData<Uint8List> {
  /// The reference to the buffer.
  final GltfRef<Buffer> buffer;

  /// The length of the bufferView in bytes.
  final int byteLength;

  /// The offset into the buffer in bytes.
  final int byteOffset;

  /// The stride, in bytes, between vertex attributes.
  ///
  /// When this is not defined, data is tightly packed.
  /// When two or more accessors use the same buffer view, this field **MUST**
  /// be defined.
  final int? byteStride;

  /// The hint representing the intended GPU buffer type to use with this
  /// buffer view.
  final BufferViewTarget? target;

  BufferView({
    required super.root,
    required this.buffer,
    required this.byteLength,
    required this.byteOffset,
    required this.byteStride,
    required this.target,
  });

  BufferView.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        buffer: Parser.ref(root, map, 'buffer')!,
        byteLength: Parser.integer(map, 'byteLength')!,
        byteOffset: Parser.integer(map, 'byteOffset') ?? 0,
        byteStride: Parser.integer(map, 'byteStride'),
        target: BufferViewTarget.parse(map, 'target'),
      );

  @override
  Future<Uint8List> loadData() async {
    return root.readChunk(buffer);
  }

  Uint8List data() {
    final data = getData();
    return data.sublist(
      byteOffset,
      byteOffset + byteLength,
    );
  }
}
