import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/primitive.dart';

/// A set of primitives to be rendered.
///
/// Its global transform is defined by a node that references it.
class Mesh({
  required super.root,

  /// An array of primitives, each defining geometry to be rendered.
  required final List<Primitive> primitives,

  /// Array of weights to be applied to the morph targets.
  /// The number of array elements **MUST** match the number of morph targets
  required final List<double>? weights,
}) extends GltfNode {
  Mesh.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        primitives:
            Parser.objectList(root, map, 'primitives', Primitive.parse) ?? [],
        weights: Parser.floatList(map, 'weights'),
      );

  // TODO(luan): remove the transform parameter
  flame_3d.Mesh toFlameMesh([Matrix4? transform]) {
    final mesh = flame_3d.Mesh();
    for (final primitive in primitives) {
      mesh.addSurface(primitive.toFlameSurface(transform));
    }
    return mesh;
  }
}
